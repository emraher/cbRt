# CBRT EDDS Series Information Data

A bundled dataset containing metadata for all available CBRT EVDS
series. This is a snapshot of metadata that ships with the package for
offline reference. For the most up-to-date metadata, use
[`cbrt_meta()`](https://eremrah.com/cbRt/reference/cbrt_meta.md).

## Usage

``` r
data(cbrt_meta_data)
```

## Format

A tibble with metadata for all available series including:

- SERIE_CODE:

  Series code (e.g., "TP.DK.USD.A")

- SERIE_NAME_ENG:

  Series name in English

- FREQUENCY_STR:

  Data frequency (e.g., "Daily", "Monthly")

- START_DATE:

  Series start date

- END_DATE:

  Series end date

## See also

[`cbrt_meta`](https://eremrah.com/cbRt/reference/cbrt_meta.md) to fetch
fresh metadata from the API

## Examples

``` r
# Load bundled metadata
data(cbrt_meta_data)

# Search for USD exchange rate series
if (FALSE) { # \dontrun{
library(dplyr)
library(stringr)

cbrt_meta_data |>
  filter(str_detect(SERIE_CODE, "USD")) |>
  select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR)
} # }
```
