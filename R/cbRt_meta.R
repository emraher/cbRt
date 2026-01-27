#' Download information for all available series
#'
#' @param token API Key
#'
#' @return A data frame with metadata for all available series
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' library(stringr)
#'
#' # Get all available series metadata
#' metadata <- cbrt_meta(token = Sys.getenv("EVDS_TOKEN"))
#'
#' # Search for exchange rate series
#' metadata |>
#'   filter(str_detect(SERIE_NAME_ENG, regex("exchange|currency", ignore_case = TRUE))) |>
#'   select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR, START_DATE, END_DATE) |>
#'   head(10)
#'
#' # Find specific series
#' metadata |>
#'   filter(SERIE_CODE == "TP.DK.USD.A")
#' }
#'
#' @export
# -------------------------------------------------------------------------- ###
# Download All Series and Store----
# -------------------------------------------------------------------------- ###
cbrt_meta <- function(token = NULL) {
  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")

  if (token == "") {
    stop("API token not found. Please provide a token or set EVDS_TOKEN environment variable.")
  }

  all_categories <- get_categories_info(token)
  all_groups <- get_groups_info(token)

  doc <- purrr::map_df(all_groups$DATAGROUP_CODE,
                       ~get_series_info(token, code = .x))

  return(doc)

}
