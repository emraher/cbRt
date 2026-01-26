
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cbRt

<!-- badges: start -->

[![lifecycle](README_files/figure-gfm/4c3e7750a6a29618a9285cbb1cb165c8afe9987f.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](README_files/figure-gfm/0d391edc738fc8ae30c9b1b85658d3b7aa7cff40.svg)](https://github.com/emraher/cbRt/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](README_files/figure-gfm/0751cb25c61484fc1cb407e24701a2f170a279e5.svg)](https://app.codecov.io/gh/emraher/cbRt?branch=main)
<!-- badges: end -->

## Overview

`cbRt` provides an R interface to the Electronic Data Delivery System
(EVDS) of the Central Bank of the Republic of Turkey (CBRT). The package
enables easy access to a rich collection of economic data including
exchange rates, interest rates, inflation indicators, and more.

**Key Features:**

- ✅ **Full EVDS API v3 support** with automatic handling of the 150
  observation limit
- ✅ **Intelligent chunking** - automatically splits large date ranges
  into multiple requests
- ✅ **Hybrid frequency detection** - detects series frequency from
  metadata with fallback
- ✅ **Multiple output formats** - tibble, tsibble, data.frame, or
  data.table
- ✅ **Formula transformations** - apply calculations at the API level
- ✅ **Clean data handling** - automatic conversion of ND values to NA

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
```

### Applying Formulas

Transform your data with built-in formulas:

``` r
# Get year-over-year percent change
usd_try_yoy <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2020",
  end_date = "01-01-2024",
  formulas = 3,  # Year-to-year percent change
  token = Sys.getenv("EVDS_TOKEN")
)
```

**Available formulas:**

- **0**: Level (default)
- **1**: Percentage change
- **2**: Difference
- **3**: Year-to-year Percent Change
- **4**: Year-to-year Differences
- **5**: Percentage Change Compared to End-of-Previous Year
- **6**: Difference Compared to End-of-Previous Year
- **7**: Moving Average
- **8**: Moving Sum

### Exploring Available Data

Use `cbrt_meta()` to discover available data series:

``` r
library(dplyr)

# Get all available series metadata
metadata <- cbrt_meta(token = Sys.getenv("EVDS_TOKEN"))

# Search for exchange rate series
metadata %>%
  filter(grepl("exchange", SERIE_NAME_ENG, ignore.case = TRUE)) %>%
  select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR, START_DATE, END_DATE) %>%
  head()
```

## New in v0.3.0: API v3 Support

The package now fully supports EVDS API v3 with automatic handling of
the 150 observation limit:

### Automatic Chunking

When you request large date ranges, the package automatically:

1.  **Detects series frequency** from API metadata
2.  **Splits the date range** into chunks of ≤150 observations
3.  **Fetches data** in multiple requests
4.  **Combines results** transparently

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
```

### Hybrid Frequency Detection

The package intelligently detects series frequencies:

- **Primary**: Queries metadata API for frequency information
- **Fallback**: Uses conservative daily frequency if detection fails
- **Supports**: Daily, business days, weekly, bi-monthly, monthly,
  quarterly, semi-annual, yearly

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

- **Getting Started Guide**: See `vignette("getting-started")` for
  comprehensive examples
- **Function Reference**: `?cbrt_get`, `?cbrt_meta`
- **Package Website**: <https://eremrah.com/cbRt/>
- **EVDS API**: <https://evds3.tcmb.gov.tr/>

## Similar Packages

- [etaymaz/CBRT](https://github.com/etaymaz/CBRT) - Alternative CBRT
  data interface

## Citation

If you use this package in your research, please cite:

``` r
citation("cbRt")
```

## Contributing

Contributions are welcome! Please see the [contributing
guide](CONTRIBUTING.md) for details.

- Report bugs or request features: [GitHub
  Issues](https://github.com/emraher/cbRt/issues)
- Submit pull requests: [GitHub Pull
  Requests](https://github.com/emraher/cbRt/pulls)

## Disclaimer

This software is in no way affiliated, endorsed, or approved by the
Central Bank of the Republic of Turkey (CBRT). It comes with absolutely
no warranty.

Please see the [CBRT
disclaimer](http://www.tcmb.gov.tr/wps/wcm/connect/TCMB+EN/TCMB+EN/Footer+Menu/Disclaimer)
which states: *“Information published in this site may be quoted by
specific reference thereto, but the use of such information for
commercial purposes shall be subject to prior written permission of the
CBRT.”*

## License

MIT License - see [LICENSE](LICENSE) file for details.
