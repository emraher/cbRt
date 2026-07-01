# cbRt

## Overview

`cbRt` provides an R interface to the Electronic Data Delivery System
(EVDS) of the Central Bank of the Republic of Turkey (CBRT). The package
enables easy access to economic data including exchange rates, interest
rates, and inflation indicators.

**Features:**

- Full EVDS API v3 support with automatic handling of the 150
  observation limit
- Intelligent chunking - automatically splits large date ranges into
  multiple requests
- Hybrid frequency detection - detects series frequency from metadata
  with fallback
- Multiple output formats - tibble, tsibble, data.frame, or data.table
- Formula transformations - apply calculations at the API level
- Clean data handling - automatic conversion of ND values to NA

## Installation

Install the development version from GitHub:

``` r

# install.packages("devtools")
devtools::install_github("emraher/cbRt")
```

## Getting Started

### API Token Setup

You need an API token from the CBRT EVDS system:

1.  Visit <https://evds3.tcmb.gov.tr/>
2.  Create an account and generate your API key

Store your token securely in your `.Renviron` file:

``` r

# Edit your .Renviron file
usethis::edit_r_environ()

# Add this line:
EVDS_TOKEN = "your_api_key_here"
```

Alternatively, set it for the current session:

``` r

Sys.setenv(EVDS_TOKEN = "your_api_key_here")
```

### Basic Usage

``` r

library(cbRt)

# Get USD/TRY exchange rate
usd_try <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2020",
  end_date = "01-01-2024",
  token = Sys.getenv("EVDS_TOKEN")
)

head(usd_try)
#> # A tibble: 6 × 2
#>   Date       TP_DK_USD_A
#>   <date>           <dbl>
#> 1 2020-01-01       NA   
#> 2 2020-01-02        5.94
#> 3 2020-01-03        5.95
#> 4 2020-01-04       NA   
#> 5 2020-01-05       NA   
#> 6 2020-01-06        5.96
```

### Multiple Series

Retrieve multiple series at once - the package handles different
frequencies automatically:

``` r

# Get multiple exchange rates
exchange_rates <- cbrt_get(
  series = c("TP.DK.USD.A", "TP.DK.EUR.A", "TP.DK.GBP.A"),
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  token = Sys.getenv("EVDS_TOKEN")
)

head(exchange_rates)
#> # A tibble: 6 × 4
#>   Date       TP_DK_USD_A TP_DK_EUR_A TP_DK_GBP_A
#>   <date>           <dbl>       <dbl>       <dbl>
#> 1 2023-01-01        NA          NA          NA  
#> 2 2023-01-02        18.7        19.9        22.5
#> 3 2023-01-03        18.7        20.0        22.5
#> 4 2023-01-04        18.7        19.8        22.3
#> 5 2023-01-05        18.7        19.8        22.5
#> 6 2023-01-06        18.7        19.9        22.5
```

### Applying Formulas

``` r

# Get year-over-year percent change
usd_try_yoy <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2020",
  end_date = "01-01-2024",
  formulas = 3,  # Year-to-year percent change
  token = Sys.getenv("EVDS_TOKEN")
)

head(usd_try_yoy)
#> # A tibble: 6 × 2
#>   Date       `TP_DK_USD_A-3`
#>   <date>               <dbl>
#> 1 2020-01-01            NA  
#> 2 2020-01-02            12.5
#> 3 2020-01-03            11.6
#> 4 2020-01-04            NA  
#> 5 2020-01-05            NA  
#> 6 2020-01-06            NA
```

Available formulas: 0 (level), 1 (percentage change), 2 (difference), 3
(year-to-year percent change), 4 (year-to-year differences), 5
(percentage change vs. end-of-previous year), 6 (difference
vs. end-of-previous year), 7 (moving average), 8 (moving sum).

### Exploring Available Data

The package includes bundled metadata for all available series, so you
can explore data offline:

``` r

library(dplyr)
library(stringr)

# Use bundled metadata (no API call needed)
data(cbrt_meta_data)

# Search for exchange rate series
cbrt_meta_data %>%
  filter(str_detect(SERIE_NAME_ENG, regex("exchange", ignore_case = TRUE))) %>%
  select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR, START_DATE, END_DATE) %>%
  head()
```

Or fetch the latest metadata directly from the API:

``` r

# Get fresh metadata from API
metadata <- cbrt_meta(token = Sys.getenv("EVDS_TOKEN"))

# Search for specific series
metadata %>%
  filter(str_detect(SERIE_CODE, "USD")) %>%
  select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR) %>%
  head()
```

## API v3 Support

The package handles the EVDS API v3 observation limit automatically:

### Automatic Chunking

For large date ranges, the package:

1.  Detects series frequency from API metadata
2.  Splits the date range into chunks of ≤150 observations
3.  Fetches data in multiple requests
4.  Combines results transparently

``` r

# This automatically chunks the request
usd_try_long <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2015",  # 9+ years of daily data
  end_date = "01-01-2024",
  token = Sys.getenv("EVDS_TOKEN")
)

# You'll see messages like:
# "Series TP.DK.USD.A: Fetching data in 5 chunks to handle 150 observation limit."

nrow(usd_try_long)  # Returns all data, not limited to 150
#> [1] 3288
```

### Frequency Detection

Series frequencies are detected from metadata API. If detection fails,
defaults to daily frequency. Supported frequencies: daily, business
days, weekly, bi-monthly, monthly, quarterly, semi-annual, yearly.

## Output Formats

Choose your preferred output format:

``` r

# Tibble (default) - for dplyr workflows
data_tibble <- cbrt_get(series, start_date, end_date, as = "tibble")

# Tsibble - for time series analysis with fable/feasts
data_tsibble <- cbrt_get(series, start_date, end_date, as = "tsibble")

# data.frame - base R compatibility
data_df <- cbrt_get(series, start_date, end_date, as = "data.frame")

# data.table - for data.table workflows
data_dt <- cbrt_get(series, start_date, end_date, as = "data.table")
```

## Documentation

- Getting Started Guide:
  [`vignette("getting-started")`](https://eremrah.com/cbRt/articles/getting-started.md)
- Function Reference:
  [`?cbrt_get`](https://eremrah.com/cbRt/reference/cbrt_get.md),
  [`?cbrt_meta`](https://eremrah.com/cbRt/reference/cbrt_meta.md)
- Package Website: <https://eremrah.com/cbRt/>
- EVDS API: <https://evds3.tcmb.gov.tr/>

## Similar Packages

- [etaymaz/CBRT](https://github.com/etaymaz/CBRT) - Alternative CBRT
  data interface

## Citation

If you use this package in your research, please cite:

``` r

citation("cbRt")
```

## Contributing

See the [contributing guide](https://eremrah.com/cbRt/CONTRIBUTING.md)
for details.

- Report bugs or request features: [GitHub
  Issues](https://github.com/emraher/cbRt/issues)
- Submit pull requests: [GitHub Pull
  Requests](https://github.com/emraher/cbRt/pulls)

## Disclaimer

This software is in no way affiliated, endorsed, or approved by the
Central Bank of the Republic of Turkey (CBRT). It comes with absolutely
no warranty.

Please see the [CBRT
disclaimer](https://www.tcmb.gov.tr/wps/wcm/connect/TCMB+EN/TCMB+EN/Footer+Menu/Disclaimer)
which states: *“Information published in this site may be quoted by
specific reference thereto, but the use of such information for
commercial purposes shall be subject to prior written permission of the
CBRT.”*

## License

MIT License - see [LICENSE](https://eremrah.com/cbRt/LICENSE) file for
details.
