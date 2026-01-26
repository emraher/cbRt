#' Get the series from CBRT
#'
#' @param series Series Code
#'
#' \code{series} argument can be obtained from CBRT webpage. Search CBRT
#' webpage in order to find out the series code and use it in the
#' \code{series} argument. The serial codes are displayed. If more than
#' one series is selected, it takes up parameters as the number of
#' series, the serial codes are separated by a "-" sign.
#'
#' @param start_date Start date
#'
#' \code{start_date} argument is the series start date as dd-mm-yyyy
#' format. In order to display the frequency of the desired series, the
#' first day of the corresponding frequency must be stated in the start
#' date as dd-mm-yyyy format.
#'
#' @param end_date End date
#'
#' \code{end_date} argument is the series end date as dd-mm-yyyy format.
#'
#' @param formulas Formulas applied to series
#'
#' \code{formulas} argument is the formula applied to series.
#'
#' Available formulas are;
#' 0: Level
#' 1: Percentage change
#' 2: Difference
#' 3: Year-to-year Percent Change
#' 4: Year-to-year Differences
#' 5: Percentage Change Compared to End-of-Previous Year
#' 6: Difference Compared to End-of-Previous Year
#' 7: Moving Average
#' 8: Moving Sum
#'
#' If more than one series is selected, it takes up parameters as the number of
#' series, the serial codes are separated by a "-" sign. If this parameter is
#' not entered by the user, the level formula parameter is applied for the
#' relevant series.
#'
#' @param token API key
#'
#' \code{token} argument is the required API key.
#' See <https://evds3.tcmb.gov.tr/> for instructions to obtain the API key.
#'
#' @section API v3 Changes:
#' The CBRT EVDS API v3 has a 150 observation limit per request. This function
#' automatically handles this limit by:
#' \itemize{
#'   \item Detecting series frequency from metadata (with fallback to daily)
#'   \item Splitting large date ranges into chunks of max 150 observations
#'   \item Fetching data in multiple requests when necessary
#'   \item Combining chunks transparently for the user
#' }
#'
#' For very large date ranges with high-frequency data (daily, business days),
#' data will be fetched in multiple chunks. Progress messages will inform you
#' when chunking occurs. Consider using aggregation formulas or narrower date
#' ranges for better performance.
#'
#' @param nd Convert ND values to NA
#'
#' \code{nd} argument is a TRUE or FALSE argument. Data retrieved sometimes
#' includes ND terms. If \code{nd} is set to TRUE, all NDs are converted to
#' NAs.
#'
#' @param as Type of data to return
#'
#' Argument \code{as} can be set to either \code{tibble}, \code{tsibble},
#' \code{data.frame}, or \code{data.table} to obtain different types of data
#' classes. \code{tibble} is the default output class.
#'
#' @return A data frame (tibble, tsibble, data.frame, or data.table)
#'
#' @examples
#' # Download the given series for the given dates
#' \dontrun{cbrt_get(series = "TP.DK.USD.A",
#'                   start_date = "01-01-2017",
#'                   end_date = "01-01-2018",
#'                   token = APIkey)}
#'
#' @export
cbrt_get <- function(series,
                     start_date,
                     end_date,
                     formulas = NULL,
                     token = NULL,
                     nd = TRUE,
                     as = c("tibble", "tsibble", "data.frame", "data.table")) {


  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN") # Get token from .Renviron

  # EVDS combines series if multiple series are requested.
  # If one yearly and one monthly requested, API converts monthly to yearly.
  # I don't want conversion.
  # I have to get all data and combine series myself.

  # EVDS API v3 has 150 observation limit per request
  # Need to detect frequency and chunk date ranges if necessary

  # Create a nested structure: series x chunks
  series_chunks <- purrr::map(series, function(s) {
    # Get series frequency (with fallback to daily)
    freq <- get_series_frequency(s, token)

    # Calculate date chunks needed
    chunks_df <- calculate_date_chunks(start_date, end_date, freq)

    # Add series code to each chunk
    chunks_df$series <- s

    # Inform user if chunking is happening
    if (nrow(chunks_df) > 1) {
      message(sprintf("Series %s: Fetching data in %d chunks to handle 150 observation limit.",
                      s, nrow(chunks_df)))
    }

    return(chunks_df)
  })

  # Flatten to get all series-chunk combinations
  all_chunks <- do.call(rbind, series_chunks)

  # Generate URLs for each series-chunk combination
  if (is.null(formulas)) {
    url <- purrr::pmap(
      list(all_chunks$series, all_chunks$chunk_start, all_chunks$chunk_end),
      function(s, start, end) cbrt_url(s, token, start, end)
    )
  } else {
    # Match formulas to series (repeat formulas if needed)
    formulas_expanded <- rep_len(formulas, length(series))
    all_chunks$formula <- formulas_expanded[match(all_chunks$series, series)]

    url <- purrr::pmap(
      list(all_chunks$series, all_chunks$chunk_start, all_chunks$chunk_end, all_chunks$formula),
      function(s, start, end, f) cbrt_url(s, token, start, end, f)
    )
  }

  # Fetch all URLs
  res <- purrr::map(.x = url, .f = ~ cbrt_geturl(.x, token))

  # We need to Check response for all urls.

  scodes <- purrr::map_dbl(.x = res, .f = ~ httr::status_code(.x))


  if (any(scodes != 200)) {
    stop("Bad Request!\n", "Please check if function arguments are correct!\n",
         "For series-chunk combination(s) ",
         paste(which(scodes != 200), collapse = ", "),
         " request returned error codes ",
         paste(scodes[which(scodes != 200)], collapse = ", "),
         " respectively.\n\n")
  }

  # Parse all responses
  df_list <- purrr::map(.x = res, .f = ~ json_read_res(.x))

  # Group by series and combine chunks for each series
  # Add series identifier to each chunk
  for (i in seq_along(df_list)) {
    df_list[[i]]$series_id <- all_chunks$series[i]
  }

  # Combine chunks by series, then combine all series
  df_by_series <- split(df_list, sapply(df_list, function(x) x$series_id[1]))

  df_combined <- purrr::map(df_by_series, function(series_dfs) {
    # Combine all chunks for this series
    combined <- dplyr::bind_rows(series_dfs)
    # Remove duplicates (in case of overlapping dates)
    combined <- dplyr::distinct(combined, Date, .keep_all = TRUE)
    # Remove series_id column
    combined$series_id <- NULL
    return(combined)
  })

  # Now combine all series using full_join
  df <- purrr::reduce(df_combined, dplyr::full_join, by = "Date") %>%
    dplyr::arrange(.data$Date) %>%
    janitor::remove_empty(which = "cols") # Remove empty (all NA) columns

  # Check if any series returned exactly 150 observations (potential truncation)
  for (series_df in df_combined) {
    if (nrow(series_df) == 150) {
      warning("One or more data chunks returned exactly 150 observations. ",
              "Data may be at the limit. Consider verifying completeness.")
    }
  }


  # Convert ND

  if (nd == TRUE) {
    df[-1] <- lapply(df[-1], function(x) suppressWarnings(as.numeric(x)))
  }

  # Output data class
  as <- match.arg(as)

  if (as == "tsibble") {
    df <- tsibble::as_tsibble(df, index = "Date")
  } else if (as == "data.frame") {
    df
  } else if (as == "data.table") {
    df <- data.table::as.data.table(df)
  } else {
    df <- tibble::as_tibble(df)
  }

  return(df)
}
