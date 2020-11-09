#' CBRT EDDS Series Information Data
#'
#' @docType data
#'
#' @usage data(cbrt_meta_data)
#'
#' @format An object of class \code{"tibble"}
#'
#' @keywords datasets
#'
#' @examples
#'
#' \dontrun{data(cbrt_meta_data)
#' cbrt_meta_data %>%
#'   dplyr::filter(SERIE_CODE %in% series) %>%
#'  dplyr::select(SERIE_CODE, FREQUENCY_STR)}
"cbrt_meta_data"
