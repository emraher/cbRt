# Download information for all available series

Download information for all available series

## Usage

``` r
cbrt_meta(token = NULL)
```

## Arguments

- token:

  API Key

## Value

A data frame with metadata for all available series

## Updating the bundled data

To update the bundled `cbrt_meta_data` dataset with fresh metadata from
the API:


    cbrt_meta_data <- cbrt_meta(token = Sys.getenv("EVDS_TOKEN"))
    usethis::use_data(cbrt_meta_data, overwrite = TRUE)

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)
library(stringr)

# Get all available series metadata
metadata <- cbrt_meta(token = Sys.getenv("EVDS_TOKEN"))

# Search for exchange rate series
metadata |>
  filter(str_detect(SERIE_NAME_ENG, regex("exchange|currency", ignore_case = TRUE))) |>
  select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR, START_DATE, END_DATE) |>
  head(10)

# Find specific series
metadata |>
  filter(SERIE_CODE == "TP.DK.USD.A")
} # }
```
