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
                     nd = TRUE,
                     as = c("tibble", "tsibble", "data.frame", "data.table")) {


  token <- Sys.getenv("EVDS_TOKEN") # Get token from .Renviron


  url <- cbrt_url(series, token, start_date, end_date)

  res <- cbrt_geturl(url)

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

  if (as == "tsibble") {
    df <- tsibble::as_tsibble(df, key = "Date")
  } else if (as == "data.frame") {
    df
  } else if (as == "data.table") {
    df <- data.table::as.data.table(df)
  } else {
    df <- tibble::as_tibble(df)
  }

  return(df)
}
