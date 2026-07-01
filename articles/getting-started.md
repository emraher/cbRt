# Getting Started with cbRt

## Introduction

The `cbRt` package provides an R interface to the Electronic Data
Delivery System (EVDS) of the Central Bank of the Republic of Turkey
(CBRT). This vignette will guide you through the basic usage of the
package.

## Installation

You can install `cbRt` from GitHub:

``` r

# Install from GitHub
# install.packages("devtools")
devtools::install_github("emraher/cbRt")
```

## Setting up API Access

To use the CBRT EVDS API, you need an API token. Follow these steps:

1.  Visit <https://evds3.tcmb.gov.tr/>
2.  Create an account or log in
3.  Navigate to your profile to generate an API key

### Storing Your Token

You can store your token in your `.Renviron` file for persistent access:

``` r

# Add this line to your .Renviron file
# You can edit it with: usethis::edit_r_environ()
EVDS_TOKEN = "your_api_key_here"
```

Alternatively, set it for the current session:

``` r

Sys.setenv(EVDS_TOKEN = "your_api_key_here")
```

## Basic Usage

### Loading the Package

``` r

library(cbRt)
library(dplyr)
library(ggplot2)
```

### Retrieving Data for a Single Series

Let’s retrieve the USD/TRY exchange rate data:

``` r

# Get USD/TRY exchange rate (buying rate)
usd_try <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2020",
  end_date = "01-01-2024",
  token = Sys.getenv("EVDS_TOKEN")
)

# View the data
head(usd_try)
```

The data is returned as a tibble with a Date column and the series
values.

### Retrieving Multiple Series

You can retrieve multiple series at once. The package will automatically
handle different frequencies:

``` r

# Get multiple exchange rates
exchange_rates <- cbrt_get(
  series = c("TP.DK.USD.A", "TP.DK.EUR.A", "TP.DK.GBP.A"),
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  token = Sys.getenv("EVDS_TOKEN")
)

# View the data structure
head(exchange_rates)
```

## Working with Formulas

The EVDS API supports various data transformations through formulas.
Available formulas:

- **0**: Level (default)
- **1**: Percentage change
- **2**: Difference
- **3**: Year-to-year Percent Change
- **4**: Year-to-year Differences
- **5**: Percentage Change Compared to End-of-Previous Year
- **6**: Difference Compared to End-of-Previous Year
- **7**: Moving Average
- **8**: Moving Sum

### Example: Percentage Changes

``` r

# Get year-to-year percent change
usd_try_yoy <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2020",
  end_date = "01-01-2024",
  formulas = 3,  # Year-to-year percent change
  token = Sys.getenv("EVDS_TOKEN")
)

head(usd_try_yoy)
```

### Multiple Series with Different Formulas

``` r

# Apply different formulas to different series
data <- cbrt_get(
  series = c("TP.DK.USD.A", "TP.DK.EUR.A"),
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  formulas = c(1, 3),  # Percentage change for USD, YoY for EUR
  token = Sys.getenv("EVDS_TOKEN")
)
```

## Exploring Available Data

### Getting Metadata

The [`cbrt_meta()`](https://eremrah.com/cbRt/reference/cbrt_meta.md)
function retrieves metadata for all available series:

``` r

# Get all available series metadata
metadata <- cbrt_meta(token = Sys.getenv("EVDS_TOKEN"))

# Explore the structure
glimpse(metadata)

# Search for specific series
metadata %>%
  filter(grepl("exchange", SERIE_NAME_ENG, ignore.case = TRUE)) %>%
  select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR, START_DATE, END_DATE) %>%
  head()
```

## Handling the 150 Observation Limit (API v3)

The EVDS API v3 has a limit of 150 observations per request. The `cbRt`
package automatically handles this by:

1.  Detecting the frequency of each series
2.  Splitting large date ranges into chunks
3.  Fetching data in multiple requests
4.  Combining the results transparently

### Example: Large Date Range

``` r

# This will automatically be chunked
usd_try_long <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2015",
  end_date = "01-01-2024",
  token = Sys.getenv("EVDS_TOKEN")
)

# The package will display messages like:
# "Series TP.DK.USD.A: Fetching data in 5 chunks to handle 150 observation limit."

# Check the number of observations
nrow(usd_try_long)
```

## Data Visualization Example

``` r

# Plot USD/TRY exchange rate
usd_try %>%
  ggplot(aes(x = Date, y = TP.DK.USD.A)) +
  geom_line(color = "#33337E", linewidth = 1) +
  labs(
    title = "USD/TRY Exchange Rate",
    subtitle = "Central Bank of Turkey (Buying Rate)",
    x = "Date",
    y = "USD/TRY",
    caption = "Source: CBRT EVDS"
  ) +
  theme_minimal()
```

## Working with Different Output Formats

By default,
[`cbrt_get()`](https://eremrah.com/cbRt/reference/cbrt_get.md) returns a
tibble, but you can specify other formats:

``` r

# As tibble (default)
data_tibble <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  as = "tibble",
  token = Sys.getenv("EVDS_TOKEN")
)

# As tsibble (for time series analysis)
data_tsibble <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  as = "tsibble",
  token = Sys.getenv("EVDS_TOKEN")
)

# As data.frame
data_df <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  as = "data.frame",
  token = Sys.getenv("EVDS_TOKEN")
)

# As data.table
data_dt <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  as = "data.table",
  token = Sys.getenv("EVDS_TOKEN")
)
```

## Handling Missing Values

CBRT data sometimes includes “ND” (No Data) values. By default, these
are converted to NA:

``` r

# ND values are automatically converted to NA (default: nd = TRUE)
data_with_na <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  nd = TRUE,  # Convert ND to NA (default)
  token = Sys.getenv("EVDS_TOKEN")
)

# Keep ND as character strings
data_with_nd <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  nd = FALSE,  # Keep ND as-is
  token = Sys.getenv("EVDS_TOKEN")
)
```

## Tips and Best Practices

1.  **Store your API token securely**: Use `.Renviron` rather than
    hardcoding it in scripts
2.  **Check metadata first**: Use
    [`cbrt_meta()`](https://eremrah.com/cbRt/reference/cbrt_meta.md) to
    find the correct series codes
3.  **Be mindful of date ranges**: Very large date ranges will result in
    multiple API calls
4.  **Use appropriate formulas**: Apply transformations at the API level
    when possible
5.  **Handle missing data**: Always check for NA values in your analysis

## Getting Help

For more information:

- Package documentation:
  [`?cbrt_get`](https://eremrah.com/cbRt/reference/cbrt_get.md),
  [`?cbrt_meta`](https://eremrah.com/cbRt/reference/cbrt_meta.md)
- Report issues: <https://github.com/emraher/cbRt/issues>
- CBRT EVDS website: <https://evds3.tcmb.gov.tr/>

## Disclaimer

This software is in no way affiliated, endorsed, or approved by the
Central Bank of the Republic of Turkey (CBRT). It comes with absolutely
no warranty.
