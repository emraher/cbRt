#' Download information for all available series
#'
#' @param token API Key
#'
#' @examples
#' # Download information for all available series
#' \dontrun{cbRt_meta(token = APIkey)}
#'
#' @export
# -------------------------------------------------------------------------- ###
# Download All Series and Store----
# -------------------------------------------------------------------------- ###
cbrt_meta <- function(token = NULL) {
  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")
  all_categories <- get_categories_info(token)
  all_groups <- get_groups_info(token)
  all_groups <- dplyr::left_join(all_groups, all_categories,
                                 by = "CATEGORY_ID") %>%
    dplyr::select(.data$TOPIC_TITLE_ENG, tidyselect::everything())

  doc <- purrr::map_df(all_groups$DATAGROUP_CODE,
                       ~get_series_info(token, code = .x))

  return(doc)

}
