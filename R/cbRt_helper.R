#' Helper functions
#'
#' @keywords internal

# -------------------------------------------------------------------------- ###
# Get Categories----
# -------------------------------------------------------------------------- ###
get_categories_info <- function(token = NULL) {
  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")
  urlroot <- "https://evds3.tcmb.gov.tr/igmevdsms-dis/categories/"
  url <- paste0(urlroot, "type=json")
  doc <- cbrt_geturl(url, token = token)
  doc <- jsonlite::fromJSON(httr::content(doc, as = "text", encoding = "UTF-8"))
  return(doc)
}


# -------------------------------------------------------------------------- ###
# Get Data Groups----
# -------------------------------------------------------------------------- ###
get_groups_info <- function(token = NULL, category_id = NULL) {
  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")
  urlroot <- "https://evds3.tcmb.gov.tr/igmevdsms-dis/datagroups/"

  if (!is.null(category_id)) {
    url <- paste0(urlroot, "mode=2&code=", category_id, "&type=json")
    doc <- cbrt_geturl(url, token = token)
    doc <- jsonlite::fromJSON(httr::content(doc, as = "text", encoding = "UTF-8"))
    doc <- doc |> dplyr::select(CATEGORY_ID, DATAGROUP_CODE,
                                 DATAGROUP_NAME_ENG, FREQUENCY,
                                 START_DATE, END_DATE,
                                 tidyselect::everything())
  } else {
    url <- paste0(urlroot, "mode=0&type=json")
    doc <- cbrt_geturl(url, token = token)
    doc <- jsonlite::fromJSON(httr::content(doc, as = "text", encoding = "UTF-8"))
    doc <- doc |> dplyr::select(CATEGORY_ID, DATAGROUP_CODE,
                                 DATAGROUP_NAME_ENG, FREQUENCY,
                                 START_DATE, END_DATE,
                                 tidyselect::everything())
    doc <- dplyr::filter(doc, DATAGROUP_CODE != "bie_bosluk1")
    doc <- dplyr::filter(doc, !is.na(START_DATE))
  }

  return(doc)

}

# -------------------------------------------------------------------------- ###
# Get Series List----
# -------------------------------------------------------------------------- ###
# code is getGroups$DATAGROUP_CODE
get_series_info <- function(token = NULL, code) {
  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")
  urlroot <- "https://evds3.tcmb.gov.tr/igmevdsms-dis/serieList/"
  url <- paste0(urlroot, "type=json&code=", code)
  doc <- cbrt_geturl(url, token = token)
  doc <- jsonlite::fromJSON(httr::content(doc, as = "text", encoding = "UTF-8"))
  doc <- doc |> dplyr::select(DATAGROUP_CODE, SERIE_CODE,
                               SERIE_NAME_ENG, FREQUENCY_STR,
                               START_DATE, END_DATE,
                               tidyselect::everything())

  return(doc)
}

# -------------------------------------------------------------------------- ###
# Get Series Frequency (for API v3 150 obs limit handling)----
# -------------------------------------------------------------------------- ###
get_series_frequency <- function(series_code, token = NULL) {
  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")

  # Try to extract datagroup code from series code
  # Series codes are typically in format: DATAGROUP_CODE.SUFFIX
  # We need to find the matching datagroup
  tryCatch({
    # Get all datagroups to find which one contains this series
    groups <- get_groups_info(token = token)

    # Try to match series code prefix with datagroup code
    # Extract the first part before any dot or underscore
    series_prefix <- sub("\\..*$", "", series_code)

    # Look for matching datagroup
    matching_group <- groups[grepl(series_prefix, groups$DATAGROUP_CODE, fixed = TRUE), ]

    if (nrow(matching_group) > 0) {
      # Get the first match
      datagroup_code <- matching_group$DATAGROUP_CODE[1]

      # Try to get series info from this datagroup
      series_info <- get_series_info(token = token, code = datagroup_code)

      # Find the specific series
      series_row <- series_info[series_info$SERIE_CODE == series_code, ]

      if (nrow(series_row) > 0 && !is.null(series_row$FREQUENCY_STR)) {
        # Map frequency string to numeric code
        freq_str <- series_row$FREQUENCY_STR[1]
        freq_map <- c(
          "Daily" = 1, "G\u00fcnl\u00fck" = 1,
          "Business" = 2, "\u0130\u015f G\u00fcn\u00fc" = 2,
          "Weekly" = 3, "Haftal\u0131k" = 3,
          "Semimonthly" = 4, "Ayda 2 Kez" = 4,
          "Monthly" = 5, "Ayl\u0131k" = 5,
          "Quarterly" = 6, "3 Ayl\u0131k" = 6,
          "Semiannual" = 7, "6 Ayl\u0131k" = 7,
          "Annual" = 8, "Y\u0131ll\u0131k" = 8
        )

        # Try to find matching frequency
        for (i in seq_along(freq_map)) {
          if (grepl(names(freq_map)[i], freq_str, ignore.case = TRUE)) {
            return(as.integer(freq_map[i]))
          }
        }
      }
    }

    # Default to daily (most conservative, safest for chunking)
    return(1L)

  }, error = function(e) {
    # On any error, default to daily frequency (conservative approach)
    message("Could not determine series frequency, using daily (conservative).")
    return(1L)
  })
}

# -------------------------------------------------------------------------- ###
# Calculate Date Chunks (for API v3 150 obs limit)----
# -------------------------------------------------------------------------- ###
calculate_date_chunks <- function(start_date, end_date, frequency_code, max_obs = 150) {
  # Parse dates (dd-mm-yyyy format)
  start_dt <- as.Date(start_date, format = "%d-%m-%Y")
  end_dt <- as.Date(end_date, format = "%d-%m-%Y")

  if (is.na(start_dt) || is.na(end_dt)) {
    stop("Invalid date format. Use dd-mm-yyyy format.")
  }

  if (start_dt > end_dt) {
    stop("Start date must be before end date.")
  }

  # Calculate observations per year based on frequency
  obs_per_year <- switch(as.character(frequency_code),
    "1" = 365,        # Daily
    "2" = 260,        # Business days (~5 per week * 52 weeks)
    "3" = 52,         # Weekly
    "4" = 24,         # Bi-monthly (twice per month)
    "5" = 12,         # Monthly
    "6" = 4,          # Quarterly
    "7" = 2,          # Semi-annual
    "8" = 1,          # Yearly
    365               # Default to daily (conservative)
  )

  # Calculate total days in range
  total_days <- as.numeric(end_dt - start_dt) + 1

  # Estimate total observations
  # For daily and business frequencies, use day-based calculation
  # For other frequencies, use year-based calculation
  if (frequency_code %in% c(1, 2)) {
    # Daily frequencies: count days
    if (frequency_code == 1) {
      estimated_obs <- total_days
    } else {
      # Business days: approximate as 5/7 of total days
      estimated_obs <- ceiling(total_days * 5 / 7)
    }
  } else {
    # Other frequencies: use years * obs_per_year
    years <- as.numeric(end_dt - start_dt) / 365.25
    estimated_obs <- ceiling(years * obs_per_year)
  }

  # If estimated observations <= max, return single chunk
  if (estimated_obs <= max_obs) {
    return(data.frame(
      chunk_start = start_date,
      chunk_end = end_date,
      stringsAsFactors = FALSE
    ))
  }

  # Need to chunk - calculate chunk size
  # For daily/business frequencies, chunk by days
  # For other frequencies, chunk by time periods that give ~max_obs observations

  chunks <- list()

  if (frequency_code %in% c(1, 2)) {
    # Daily/business day chunking: split by days
    if (frequency_code == 1) {
      days_per_chunk <- max_obs
    } else {
      # Business days: need ~max_obs business days, which is ~max_obs * 7/5 calendar days
      days_per_chunk <- ceiling(max_obs * 7 / 5)
    }

    current_start <- start_dt
    chunk_num <- 1

    while (current_start <= end_dt) {
      # Calculate chunk end (subtract 1 to avoid overlap)
      chunk_end_dt <- min(current_start + days_per_chunk - 1, end_dt)

      chunks[[chunk_num]] <- data.frame(
        chunk_start = format(current_start, "%d-%m-%Y"),
        chunk_end = format(chunk_end_dt, "%d-%m-%Y"),
        stringsAsFactors = FALSE
      )

      # Move to next chunk (start day after current chunk end)
      current_start <- chunk_end_dt + 1
      chunk_num <- chunk_num + 1
    }

  } else {
    # Non-daily frequencies: chunk by time periods
    # Calculate days that give us ~max_obs observations
    days_per_chunk <- ceiling((max_obs / obs_per_year) * 365.25)

    current_start <- start_dt
    chunk_num <- 1

    while (current_start <= end_dt) {
      chunk_end_dt <- min(current_start + days_per_chunk - 1, end_dt)

      chunks[[chunk_num]] <- data.frame(
        chunk_start = format(current_start, "%d-%m-%Y"),
        chunk_end = format(chunk_end_dt, "%d-%m-%Y"),
        stringsAsFactors = FALSE
      )

      current_start <- chunk_end_dt + 1
      chunk_num <- chunk_num + 1
    }
  }

  # Combine all chunks into a data frame
  do.call(rbind, chunks)
}


# -------------------------------------------------------------------------- ###
# Check Frequency----
# -------------------------------------------------------------------------- ###
# check_frequency <- function(freq) {
#   # Check if frequency is given
#   if (is.null(freq)) {
#     frequency_url <- ""
#   } else if (length(freq) == 1L) {
#     if (freq %in% c(1:8)) {
#       frequency_url <- paste0("&frequency=", freq)
#     } else {
#       stop("frequency must be either 1, 2, 3, 4, 5, 6, 7, or 8!")
#     }
#   } else {
#     stop("frequency takes single value!")
#   }
#
#   return(frequency_url)
# }

# -------------------------------------------------------------------------- ###
# Check Aggregation Type----
# -------------------------------------------------------------------------- ###
# check_aggregation_type <- function(aggregation_types) {
#   # Check if aggregation_types is given
#   if (is.null(aggregation_types)) {
#     aggregation_types_url <- ""
#   } else if (length(aggregation_types) == 1L) {
#     if (all(aggregation_types %in% c("default", "avg", "min", "max",
#                                      "first", "last", "sum"))) {
#       aggregation_types_url <- paste0("&aggregationTypes=", aggregation_types)
#     } else {
#       stop("aggregation_types must be either default, avg, min, max,
#              first, last, or sum!")
#     }
#   } else {
#     if (all(aggregation_types %in% c("default", "avg", "min", "max",
#                                      "first", "last", "sum"))) {
#       aggregation_types_url <- paste0("&aggregationTypes=",
#                                       paste(aggregation_types,
#                                             collapse = "-"))
#       series_url <- paste0("series=", paste(rep(series,
#                                                 length(aggregation_types)),
#                                             collapse = "-"))
#     } else {
#       stop("aggregation_types must be either default,
#              avg, min, max, first, last, or sum!")
#     }
#   }
#
#   return(aggregation_types_url)
# }

# -------------------------------------------------------------------------- ###
# Check Formulas----
# -------------------------------------------------------------------------- ###
check_formulas <- function(series, formulas) {
  # Check if formulas is given
  if (is.null(formulas)) {
    formulas_url <- ""
  } else if (all(formulas %in% c(0:8))) {
      formulas_url <- paste0("&formulas=", paste(formulas, collapse = "-"))
    } else {
      stop("formulas must be either 0, 1, 2, 3, 4, 5, 6, 7, or 8!")
    }
  return(formulas_url)
}

# -------------------------------------------------------------------------- ###
# Create URL----
# -------------------------------------------------------------------------- ###
cbrt_url <- function(series,
                     token = NULL,
                     start_date,
                     end_date,
                     formulas = NULL) {

  # Check if user provided required fields
  if (missing(series) || missing(start_date) || missing(end_date)) {
    stop("You must provide series, start and end dates, and API token!")
  }

  if (is.null(series) || is.null(start_date) || is.null(end_date)) {
    stop("You must provide series, start and end dates, and API token!")
  }

  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")

  if (is.null(token)) {
    stop("You must provide series, start and end dates, and API token!")
  }

  # Create URLs
  series_url <- paste0("series=", paste(series, collapse = "-"))
  start_date_url <- paste0("&startDate=", start_date)
  end_date_url <- paste0("&endDate=", end_date)
  # token_url <- paste0("&key=", token)
  type_url <- paste0("&type=json")

  formulas_url <- check_formulas(series, formulas)
  # frequency_url <- check_frequency(freq)

  # URL
  url <- paste0("https://evds3.tcmb.gov.tr/igmevdsms-dis/",
                series_url, start_date_url, end_date_url,
                type_url, formulas_url)
  return(url)
}

# -------------------------------------------------------------------------- ###
# Get URL----
# -------------------------------------------------------------------------- ###
cbrt_geturl <- function(url, token, ...) {
  httr::GET(url = url, httr::add_headers(key = token))
}


# -------------------------------------------------------------------------- ###
# Convert json to tibble----
# -------------------------------------------------------------------------- ###
# If responses are OK, we read json and save all data to tibble.
json_read_res <- function(res) {

  # Read contents
  res_json <- httr::content(res, as = "raw", encoding = "UTF-8")
  res_json <- rawToChar(res_json)

  # Extract data
  res_df <- jsonlite::fromJSON(res_json)
  df <- res_df[2]$items

  # Fix dates
  if ("Tarih" %in% colnames(df)) df$Tarih <- NULL
  if ("YEARWEEK" %in% colnames(df)) df$YEARWEEK <- NULL
  if ("UNIXTIME" %in% colnames(df)) {
    df <- within(df, {
      UNIXTIME <- anytime::anydate(as.numeric(df$UNIXTIME$`$numberLong`))
    })
  }
  names(df)[names(df) == "UNIXTIME"] <- "Date"

  # Reorder columns
  df <- df |> dplyr::select(Date, tidyselect::everything())

  return(df)
}
