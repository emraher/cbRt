#' Helper functions
#'
#' @keywords internal

# -------------------------------------------------------------------------- ###
# Get Categories----
# -------------------------------------------------------------------------- ###
get_categories_info <- function(token = NULL) {
  if (is.null(token)) CBRTKey <- myCBRTKey <- Sys.getenv("EVDS_TOKEN")
  urlroot <- "https://evds2.tcmb.gov.tr/service/evds/categories/"
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
  urlroot <- "https://evds2.tcmb.gov.tr/service/evds/datagroups/"

  if (!is.null(category_id)) {
    url <- paste0(urlroot, "mode=2&code=", category_id, "&type=json")
    doc <- cbrt_geturl(url, token = token)
    doc <- jsonlite::fromJSON(httr::content(doc, as = "text", encoding = "UTF-8"))
    doc <- doc %>% dplyr::select(CATEGORY_ID, DATAGROUP_CODE,
                                 DATAGROUP_NAME_ENG, FREQUENCY,
                                 START_DATE, END_DATE,
                                 tidyselect::everything())
  } else {
    url <- paste0(urlroot, "mode=0&type=json")
    doc <- cbrt_geturl(url, token = token)
    doc <- jsonlite::fromJSON(httr::content(doc, as = "text", encoding = "UTF-8"))
    doc <- doc %>% dplyr::select(CATEGORY_ID, DATAGROUP_CODE,
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
  urlroot <- "https://evds2.tcmb.gov.tr/service/evds/serieList/"
  url <- paste0(urlroot, "type=json&code=", code)
  doc <- cbrt_geturl(url, token = token)
  doc <- jsonlite::fromJSON(httr::content(doc, as = "text", encoding = "UTF-8"))
  doc <- doc %>% dplyr::select(DATAGROUP_CODE, SERIE_CODE,
                               SERIE_NAME_ENG, FREQUENCY_STR,
                               START_DATE, END_DATE,
                               tidyselect::everything())

  return(doc)
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

  # TODO -----------------------------------------------------------------------
  # Check if date format is correct

  # Create URLs
  series_url <- paste0("series=", paste(series, collapse = "-"))
  start_date_url <- paste0("&startDate=", start_date)
  end_date_url <- paste0("&endDate=", end_date)
  # token_url <- paste0("&key=", token)
  type_url <- paste0("&type=json")

  formulas_url <- check_formulas(series, formulas)
  # frequency_url <- check_frequency(freq)

  # URL
  url <- paste0("https://evds2.tcmb.gov.tr/service/evds/",
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
  df <- df %>% dplyr::select(Date, tidyselect::everything())

  return(df)
}
