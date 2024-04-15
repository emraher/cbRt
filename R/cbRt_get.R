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
#' See <https://evds2.tcmb.gov.tr/help/videos/EVDS_Web_Service_Usage_Guide.pdf>
#' for instructions to obtain the API key.
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


  token <- Sys.getenv("EVDS_TOKEN") # Get token from .Renviron

  # EVDS combines series if multiple series are requested.
  # If one yearly and one monthly requested, API converts monthly to yearly.
  # I don't want conversion.
  # I have to get all data and combine series myself.

  if (is.null(formulas)) {
    url <- purrr::map(.x = series,
                      .f = ~ cbrt_url(.x, token, start_date, end_date))
  } else {
    url <- purrr::map2(.x = series,
                       .y = formulas,
                       .f = ~ cbrt_url(.x, token, start_date, end_date, .y))
  }



  res <- purrr::map(.x = url, .f = ~ cbrt_geturl(.x, token))

  # We need to Check response for all urls.

  scodes <- purrr::map_dbl(.x = res, .f = ~ httr::status_code(.x))


  if (any(scodes != 200)) {
    stop("Bad Request!\n", "Please check if function arguments are correct!\n",
         "For series ",
         paste(which(scodes != 200), collapse = ", "),
         " request returned error codes ",
         paste(scodes[which(scodes != 200)], collapse = ", "),
         " respectively.\n\n")
  }

  df <- purrr::map(.x = res, .f = ~ json_read_res(.x)) %>%
    purrr::reduce(dplyr::full_join, by = "Date") %>%
    dplyr::arrange(.data$Date) %>%
    janitor::remove_empty(which = "cols") # Remove empty (all NA) columns


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
