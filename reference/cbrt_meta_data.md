# CBRT EDDS Series Information Data

CBRT EDDS Series Information Data

## Usage

``` r
data(cbrt_meta_data)
```

## Format

An object of class `"tibble"`

## Examples

``` r
if (FALSE) data(cbrt_meta_data)
cbrt_meta_data %>%
  dplyr::filter(SERIE_CODE %in% series) %>%
 dplyr::select(SERIE_CODE, FREQUENCY_STR) # \dontrun{}
#> Error in dplyr::filter(., SERIE_CODE %in% series): ℹ In argument: `SERIE_CODE %in% series`.
#> Caused by error:
#> ! object 'series' not found
```
