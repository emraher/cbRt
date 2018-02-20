#' Helper functions
#'
#' @keywords internal


# Create URL -------------------------------------------------------------------
cbRt_url <- function(series, startDate, endDate, token, aggregationTypes = NULL, formulas = NULL, freq = NULL) {
  # Check if user provided required fields
  if (missing(series) || missing(startDate) || missing(endDate) || missing(token)) {
    stop("You must provide series, start and end dates, and API token!")
  }

  if (is.null(series) || is.null(startDate) || is.null(endDate) || is.null(token)) {
    stop("You must provide series, start and end dates, and API token!")
  }

  # TODO -----------------------------------------------------------------------
  # Check if date format is correct

  # Check if user provided correct type. If not set to json.
  # if (!(type %in% c("csv", "xml", "json")))
  #   stop("type must be either csv, json, or xml!")

  # TODO -----------------------------------------------------------------------
  # Add support for other file types
  # if ((type %in% c("csv", "xml")))
  #   stop("At the moment only json is supported!")

  # Create URLs
  startDateURL <- paste0("&startDate=", startDate)
  endDateURL <- paste0("&endDate=", endDate)
  tokenURL <- paste0("&key=", token)
  typeURL <- paste0("&type=json")

  # Check if frequency is given
  if (is.null(freq)) {
    frequencyURL <- ""
  } else if (length(freq) == 1L) {
    if (freq %in% c(1:8)) {
      frequencyURL <- paste0("&frequency=", freq)
    } else {
      stop("frequency must be either 1, 2, 3, 4, 5, 6, 7, or 8!")
    }
  } else {
    stop("frequency takes single value!")
  }

  # Check if series length is greater than 1
  if (length(series) == 1L) {
    seriesURL <- paste0("series=", series)

    # Check if aggregationTypes is given
    if (is.null(aggregationTypes)) {
      aggregationTypesURL <- ""
    } else if (length(aggregationTypes) == 1L) {
      if (all(aggregationTypes %in% c("default", "avg", "min", "max", "first", "last", "sum"))) {
        aggregationTypesURL <- paste0("&aggregationTypes=", aggregationTypes)
      } else {
        stop("aggregationTypes must be either default, avg, min, max, first, last, or sum!")
      }
    } else {
      # stop("aggregationTypes must be same length as series!")
      if (all(aggregationTypes %in% c("default", "avg", "min", "max", "first", "last", "sum"))) {
        aggregationTypesURL <- paste0("&aggregationTypes=", paste(aggregationTypes, collapse = "-"))
        seriesURL <- paste0("series=", paste(rep(series, length(aggregationTypes)), collapse = "-"))
      } else {
        stop("aggregationTypes must be either default, avg, min, max, first, last, or sum!")
      }
    }

    # Check if formulas is given
    if (is.null(formulas)) {
      formulasURL <- ""
    } else if (length(formulas) == 1L) {
      if (formulas %in% c(0:8)) {
        formulasURL <- paste0("&formulas=", formulas)
      } else {
        stop("formulas must be either 0, 1, 2, 3, 4, 5, 6, 7, or 8!")
      }
    } else {
      # stop("formulas must be same length as series!")
      if (all(formulas %in% c(0:8))) {
        formulasURL <- paste0("&formulas=", paste(formulas, collapse = "-"))
        seriesURL <- paste0("series=", paste(rep(series, length(formulas)), collapse = "-"))
      } else {
        stop("formulas must be either 0, 1, 2, 3, 4, 5, 6, 7, or 8!")
      }
    }
  } else { # Series length is greater than 1
    nseries <- length(series)
    series <- paste(series, collapse = "-")
    seriesURL <- paste0("series=", series)

    # Check if aggregationTypes is given
    if (is.null(aggregationTypes)) {
      aggregationTypesURL <- ""
    } else if (length(aggregationTypes) == 1L) {
      if (all(aggregationTypes %in% c("default", "avg", "min", "max", "first", "last", "sum"))) {
        aggregationTypesURL <- paste0("&aggregationTypes=", paste(rep(aggregationTypes, nseries), collapse = "-"))
      } else {
        stop("aggregationTypes must be either default, avg, min, max, first, last, or sum!")
      }
    } else if (length(aggregationTypes) == nseries) {
      if (all(aggregationTypes %in% c("default", "avg", "min", "max", "first", "last", "sum"))) {
        aggregationTypesURL <- paste0("&aggregationTypes=", paste(aggregationTypes, collapse = "-"))
      } else {
        stop("aggregationTypes must be either default, avg, min, max, first, last, or sum!")
      }
    } else {
      stop("aggregationTypes must be same length as series!")
    }

    # Check if formulas is given
    if (is.null(formulas)) {
      formulasURL <- paste0("")
    } else if (length(formulas) == 1L) {
      if (all(formulas %in% c(0:8))) {
        formulasURL <- paste0("&formulas=", paste(rep(formulas, nseries), collapse = "-"))
      } else {
        stop("formulas must be either 0, 1, 2, 3, 4, 5, 6, 7, or 8!")
      }
    } else if (length(formulas) == nseries) {
      if (all(formulas %in% c(0:8))) {
        formulasURL <- paste0("&formulas=", paste(formulas, collapse = "-"))
      } else {
        stop("formulas must be either 0, 1, 2, 3, 4, 5, 6, 7, or 8!")
      }
    } else {
      stop("formulas must be same length as series!")
    }
  }
  url <- paste0("https://evds2.tcmb.gov.tr/service/evds/", seriesURL, startDateURL, endDateURL, typeURL, tokenURL, aggregationTypesURL, formulasURL, frequencyURL)
  return(url)
}


# Get URL ----------------------------------------------------------------------
cbRt_geturl <- function(url, ...) {
  httr::GET(url = url)
}
