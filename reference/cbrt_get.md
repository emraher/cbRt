# Get the series from CBRT

Get the series from CBRT

## Usage

``` r
cbrt_get(
  series,
  start_date,
  end_date,
  formulas = NULL,
  token = NULL,
  nd = TRUE,
  as = c("tibble", "tsibble", "data.frame", "data.table")
)
```

## Arguments

- series:

  Series Code

  `series` argument can be obtained from CBRT webpage. Search CBRT
  webpage in order to find out the series code and use it in the
  `series` argument. The serial codes are displayed. If more than one
  series is selected, it takes up parameters as the number of series,
  the serial codes are separated by a "-" sign.

- start_date:

  Start date

  `start_date` argument is the series start date as dd-mm-yyyy format.
  In order to display the frequency of the desired series, the first day
  of the corresponding frequency must be stated in the start date as
  dd-mm-yyyy format.

- end_date:

  End date

  `end_date` argument is the series end date as dd-mm-yyyy format.

- formulas:

  Formulas applied to series

  `formulas` argument is the formula applied to series.

  Available formulas are; 0: Level 1: Percentage change 2: Difference 3:
  Year-to-year Percent Change 4: Year-to-year Differences 5: Percentage
  Change Compared to End-of-Previous Year 6: Difference Compared to
  End-of-Previous Year 7: Moving Average 8: Moving Sum

  If more than one series is selected, it takes up parameters as the
  number of series, the serial codes are separated by a "-" sign. If
  this parameter is not entered by the user, the level formula parameter
  is applied for the relevant series.

- token:

  API key

  `token` argument is the required API key. See
  <https://evds3.tcmb.gov.tr/> for instructions to obtain the API key.

- nd:

  Convert ND values to NA

  `nd` argument is a TRUE or FALSE argument. Data retrieved sometimes
  includes ND terms. If `nd` is set to TRUE, all NDs are converted to
  NAs.

- as:

  Type of data to return

  Argument `as` can be set to either `tibble`, `tsibble`, `data.frame`,
  or `data.table` to obtain different types of data classes. `tibble` is
  the default output class.

## Value

A data frame (tibble, tsibble, data.frame, or data.table)

## API v3 Changes

The CBRT EVDS API v3 has a 150 observation limit per request. This
function automatically handles this limit by:

- Detecting series frequency from metadata (with fallback to daily)

- Splitting large date ranges into chunks of max 150 observations

- Fetching data in multiple requests when necessary

- Combining chunks transparently for the user

For very large date ranges with high-frequency data (daily, business
days), data will be fetched in multiple chunks. Progress messages will
inform you when chunking occurs. Consider using aggregation formulas or
narrower date ranges for better performance.

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)

# Download USD/TRY exchange rate
usd_try <- cbrt_get(
  series = "TP.DK.USD.A",
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  token = Sys.getenv("EVDS_TOKEN")
)

# Multiple series with formulas
exchange_rates <- cbrt_get(
  series = c("TP.DK.USD.A", "TP.DK.EUR.A"),
  start_date = "01-01-2023",
  end_date = "01-01-2024",
  formulas = c(0, 3),  # Level for USD, YoY % change for EUR
  token = Sys.getenv("EVDS_TOKEN")
)
} # }
```
