#' Helper functions
#'
#' @keywords internal

# -------------------------------------------------------------------------- ###
# Get Categories----
# -------------------------------------------------------------------------- ###
get_categories_info <- function(token = NULL) {
  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")
  urlroot <- "https://evds2.tcmb.gov.tr/service/evds/categories/key="
  url <- paste0(urlroot, token, "&type=json")
  doc <- jsonlite::fromJSON(url)
  return(doc)
}

# -------------------------------------------------------------------------- ###
# Get Data Groups----
# -------------------------------------------------------------------------- ###
get_groups_info <- function(token = NULL, category_id = NULL) {
  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")
  urlroot <- "https://evds2.tcmb.gov.tr/service/evds/datagroups/key="

  if (!is.null(category_id)) {
    url <- paste0(urlroot, token, "&mode=2&code=", category_id, "&type=json")
    doc <- jsonlite::fromJSON(url)
    doc <- doc %>% dplyr::select(.data$CATEGORY_ID, .data$DATAGROUP_CODE,
                                 .data$DATAGROUP_NAME_ENG, .data$FREQUENCY,
                                 .data$START_DATE, .data$END_DATE,
                                 tidyselect::everything())
  } else {
    url <- paste0(urlroot, token, "&mode=0&type=json")
    doc <- jsonlite::fromJSON(url)
    doc <- doc %>% dplyr::select(.data$CATEGORY_ID, .data$DATAGROUP_CODE,
                                 .data$DATAGROUP_NAME_ENG, .data$FREQUENCY,
                                 .data$START_DATE, .data$END_DATE,
                                 tidyselect::everything())
    doc <- dplyr::filter(doc, .data$DATAGROUP_CODE != "bie_bosluk1")
    doc <- dplyr::filter(doc, !is.na(.data$START_DATE))
  }

  return(doc)

}

# -------------------------------------------------------------------------- ###
# Get Series List----
# -------------------------------------------------------------------------- ###
# code is getGroups$DATAGROUP_CODE
get_series_info <- function(token = NULL, code) {
  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")
  urlroot <- "https://evds2.tcmb.gov.tr/service/evds/serieList/key="
  url <- paste0(urlroot, token, "&type=json&code=", code)
  doc <- jsonlite::fromJSON(url)
  doc <- doc %>% dplyr::select(.data$DATAGROUP_CODE, .data$SERIE_CODE,
                               .data$SERIE_NAME_ENG, .data$FREQUENCY_STR,
                               .data$START_DATE, .data$END_DATE,
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
#                                       paste(aggregation_types, collapse = "-"))
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
# check_formulas <- function(formulas) {
#   # Check if formulas is given
#   if (is.null(formulas)) {
#     formulas_url <- ""
#   } else if (length(formulas) == 1L) {
#     if (formulas %in% c(0:8)) {
#       formulas_url <- paste0("&formulas=", formulas)
#     } else {
#       stop("formulas must be either 0, 1, 2, 3, 4, 5, 6, 7, or 8!")
#     }
#   } else {
#     if (all(formulas %in% c(0:8))) {
#       formulas_url <- paste0("&formulas=", paste(formulas, collapse = "-"))
#       series_url <- paste0("series=", paste(rep(series, length(formulas)),
#                                             collapse = "-"))
#     } else {
#       stop("formulas must be either 0, 1, 2, 3, 4, 5, 6, 7, or 8!")
#     }
#   }
#
#   return(formulas_url)
# }

# -------------------------------------------------------------------------- ###
# Create URL----
# -------------------------------------------------------------------------- ###
cbrt_url <- function(series, token = NULL, start_date, end_date) {
  # Check if user provided required fields
  if (missing(series) || missing(start_date) || missing(end_date)) {
    stop("You must provide series, start and end dates, and API token!")
  }

  if (is.null(series) || is.null(start_date) || is.null(end_date)) {
    stop("You must provide series, start and end dates, and API token!")
  }

  if (is.null(token)) token <- Sys.getenv("EVDS_TOKEN")

  # TODO -----------------------------------------------------------------------
  # Check if date format is correct

  # Create URLs
  start_date_url <- paste0("&startDate=", start_date)
  end_date_url <- paste0("&endDate=", end_date)
  token_url <- paste0("&key=", token)
  type_url <- paste0("&type=json")
  # frequency_url <- check_frequency(freq)

  # Check if series length is greater than 1
  if (length(series) == 1L) {

    series_url <- paste0("series=", series)
    # aggregation_types_url <- check_aggregation_type(aggregation_types)
    # formulas_url <- check_formulas(formulas)

  } else {# Series length is greater than 1
    # nseries <- length(series)
    series <- paste(series, collapse = "-")
    series_url <- paste0("series=", series)
    # aggregation_types_url <- check_aggregation_type(aggregation_types)
    # formulas_url <- check_formulas(formulas)
  }

  url <- paste0("https://evds2.tcmb.gov.tr/service/evds/",
                series_url, start_date_url, end_date_url, type_url, token_url)
  return(url)
}

# -------------------------------------------------------------------------- ###
# Get URL----
# -------------------------------------------------------------------------- ###
cbrt_geturl <- function(url, ...) {
  httr::GET(url = url)
}
