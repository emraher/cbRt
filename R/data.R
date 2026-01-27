#' CBRT EDDS Series Information Data
#'
#' A bundled dataset containing metadata for all available CBRT EVDS series.
#' This is a snapshot of metadata that ships with the package for offline
#' reference. For the most up-to-date metadata, use \code{cbrt_meta()}.
#'
#' @docType data
#'
#' @usage data(cbrt_meta_data)
#'
#' @format A tibble with metadata for all available series including:
#' \describe{
#'   \item{SERIE_CODE}{Series code (e.g., "TP.DK.USD.A")}
#'   \item{SERIE_NAME_ENG}{Series name in English}
#'   \item{FREQUENCY_STR}{Data frequency (e.g., "Daily", "Monthly")}
#'   \item{START_DATE}{Series start date}
#'   \item{END_DATE}{Series end date}
#' }
#'
#' @keywords datasets
#'
#' @seealso \code{\link{cbrt_meta}} to fetch fresh metadata from the API
#'
#' @examples
#' # Load bundled metadata
#' data(cbrt_meta_data)
#'
#' # Search for USD exchange rate series
#' \dontrun{
#' library(dplyr)
#' library(stringr)
#'
#' cbrt_meta_data |>
#'   filter(str_detect(SERIE_CODE, "USD")) |>
#'   select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR)
#' }
"cbrt_meta_data"
