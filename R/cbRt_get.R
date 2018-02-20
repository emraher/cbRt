#' Get the series from CBRT
#'
#' @param series Series Code
#'
#' \code{series} argument can be obtained from CBRT webpage. Search CBRT webpage
#' in order to find out the series code and use it in the \code{series} argument.
#' The serial codes are displayed. If more than one series is selected, it takes
#' up parameters as the number of series, the serial codes are separated by
#' a "-" sign.
#'
#' @param startDate Start date
#'
#' \code{startDate} argument is the series start date as dd-mm-yyyy format.
#' In order to display the frequency of the desired series, the first day of the
#' corresponding frequency must be stated in the start date as dd-mm-yyyy format.
#'
#' @param endDate End date
#'
#' \code{endDate} argument is the series end date as dd-mm-yyyy format.
#'
#' @param token API key
#'
#' \code{token} argument is the required API key.
#' See <https://evds2.tcmb.gov.tr/help/videos/EVDS_Web_Service_Usage_Guide.pdf>
#' for instructions to obtain the API key.
#'
#' @param aggregationTypes Aggregation type
#'
#' \code{aggregationTypes} argument is the aggregation applied to series.
#' Available aggregations are;
#' avg   : Average
#' min   : Minimum
#' max   : Maximum
#' first : Beginning
#' last  : End
#' sum   : Cumulative
#' If more than one series is selected, it takes up parameters as the number of
#' series, the serial codes are separated by a "-" sign.
#' If this parameter is not entered by the user, the original observation
#' parameter is applied for the relevant series.
#'
#' @param formulas Formulas applied to series
#'
#' \code{formulas} argument is the formula applied to series.
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
#' If more than one series is selected, it takes up parameters as the number of
#' series, the serial codes are separated by a "-" sign. If this parameter is
#' not entered by the user, the level formula parameter is applied for the
#' relevant series.
#'
#' @param freq Frequency of series
#'
#' \code{freq} argument is the frequency of the series.
#' Available frequencies are;
#' 1: Daily
#' 2: Business
#' 3: Weekly (Friday)
#' 4: Twicemonthly
#' 5: Monthly
#' 6: Quarterly
#' 7: Semiannual
#' 8: Annual
#' This parameter takes a single value. If this parameter is not entered by the
#' user, the common frequency of the series is taken. If you enter a higher
#' frequency (eg: monthly) than the common frequency of the series (eg: annually),
#' the common frequency of the series is taken into account (eg: annually).
#'
#' @param nd Convert ND values to NA
#'
#' \code{nd} argument is a TRUE or FALSE argument. Data retrieved sometimes
#' includes ND terms. If \code{nd} is set to TRUE, all NDs are converted to
#' NAs.
#'
#' @param as Type of data to return
#'
#' @return
#' Argument \code{as} can be set to either \code{tibble}, \code{tibbletime},
#' \code{data.frame}, or \code{data.table} to obtain different types of data
#' classes. \code{tibble} is the default output class.
#'
#'
#' @examples
#' # Download the given series for the given dates
#' \dontrun{get_series(series = "TP.DK.USD.A",
#'                     startDate = "01-01-2017",
#'                     endDate = "01-01-2018",
#'                     token = APIkey)}
#'
#' @export
cbRt_get <- function(series,
                     startDate,
                     endDate,
                     token,
                     aggregationTypes = NULL,
                     formulas = NULL,
                     freq = NULL,
                     nd = TRUE,
                     as = c("tibble", "tibbletime", "data.frame", "data.table")) {
  url <- cbRt_url(series, startDate, endDate, token, aggregationTypes, formulas, freq)
  res <- cbRt_geturl(url)

  # Check response
  if (res$status_code != 200) {
    stop("Bad Request, Error: ", res$status_code)
  }

  # Read contents
  res_json <- httr::content(res, as = "raw", encoding = "UTF-8")
  res_json <- rawToChar(res_json)

  # Extract data
  res_df <- jsonlite::fromJSON(res_json)
  df <- res_df[2]$items

  # Fix dates
  if ("Tarih" %in% colnames(df)) df$Tarih <- NULL
  if ("UNIXTIME" %in% colnames(df)) {
    df <- within(df, {
      UNIXTIME <- anytime::anydate(as.numeric(df$UNIXTIME$`$numberLong`))
    })
  }
  names(df)[names(df) == "UNIXTIME"] <- "Date"

  # Reorder columns
  # https://stackoverflow.com/a/39449541
  # https://stackoverflow.com/users/6822273/ht-079
  df <- df[, c(which(colnames(df) == "Date"), which(colnames(df) != "Date"))]

  # Convert ND

  if (nd == TRUE) {
    df[-1] <- lapply(df[-1], function(x) suppressWarnings(as.numeric(x)))
  }

  # Output data class
  as <- match.arg(as)

  if (as == "tibbletime") {
    df <- tibbletime::as_tbl_time(df, index = "Date")
  } else if (as == "data.frame") {
    df
  } else if (as == "data.table") {
    df <- data.table::as.data.table(df)
  } else {
    df <- tibble::as_tibble(df)
  }

  return(df)
}
