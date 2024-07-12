
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cbRt

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

## Disclaimer

This software is in no way affiliated, endorsed, or approved by the
CBRT. It comes with absolutely no warranty. Also see the [Disclaimer on
CBRT
webpage](http://www.tcmb.gov.tr/wps/wcm/connect/TCMB+EN/TCMB+EN/Footer+Menu/Disclaimer)
since it mentions; **“Information published in this site may be quoted
by specific reference thereto, but the use of such information for
commercial purposes shall be subject to prior written permission of the
CBRT.”**

## Overview

`cbRt` is an R interface to The Electronic Data Delivery System (EDDS)
of Central Bank of the Republic of Turkey (CBRT). “The system provides a
rich range of economic data and information to support economic
education and foster economic
research.”<sup>[\[1\]](https://evds2.tcmb.gov.tr/help/videos/hakkindaEN.pdf)</sup>

### Similar Packages

- See [etaymaz/CBRT](https://github.com/etaymaz/CBRT)

## Installation

You can install `cbRt` from github with:

``` r
# install.packages("devtools")
devtools::install_github("emraher/cbRt")
```

## Usage and Arguments

There are two functions in the package.

`cbrt_meta` retrieves all information for all series.

``` r
series_meta_info <- cbrt_meta(token = NULL)
```

For `token` argument see the definition below. This returns a tibble.
One can search this tibble to find series IDs and other information on
series.

The other function is `cbrt_get` which retrieves data from EDDS.

``` r
cbrt_get(series, start_date, end_date, formulas, token = NULL, nd = TRUE,
         as = c("tibble", "tsibble", "data.frame", "data.table"))
```

Following are the arguments used in the functions. Descriptions are
taken from [EDDS Web Service Usage
Guide](https://evds2.tcmb.gov.tr/help/videos/EVDS_Web_Service_Usage_Guide.pdf).

**Note that,** `series`**,** `start_date`**,** `end_date`**,** **and**
`token` **are all required arguments.**

### `series`

`series` argument can be obtained from CBRT webpage. [Search CBRT
webpage](https://evds2.tcmb.gov.tr) in order to find out the series code
and use it in the `series` argument. For example, `TP.DK.USD.A` is the
code for **(USDTRY) US Dollar (Buying) Exchange Rate**.

One can also use `cbrt_meta` function to get all information for all
series and search in the resulting tibble.

Argument can take multiple values.

### `start_date`

`start_date` argument is the series start date as `dd-mm-yyyy` format.
**This argument takes a single value.**

### `end_date`

`end_date` argument is the series end date as `dd-mm-yyyy` format.
**This argument takes a single value.**

### `formulas`

`formulas` argument is the formula applied to series. Available formulas
are;

- **0**: Level
- **1**: Percentage Change
- **2**: Difference
- **3**: Year-to-year Percent Change
- **4**: Year-to-year Differences
- **5**: Percentage Change Compared to End-of-Previous Year
- **6**: Difference Compared to End-of-Previous Year
- **7**: Moving Average
- **8**: Moving Sum

If this parameter is not supplied by the user, the level formula
parameter is applied for the relevant series. If retrieving multiple
series, argument should take multiple values.

### `token`

`token` argument is the required API key. [Follow the instructions on
CBRT
webpage](https://evds2.tcmb.gov.tr/help/videos/EVDS_Web_Service_Usage_Guide.pdf)
to obtain the user specific API key. **This argument takes a single
value.**

You can set your token with

    Sys.setenv(EVDS_TOKEN = "Iq83AIL5bss")

or you can add it to your `.Renviron` file as

    EVDS_TOKEN = "Iq83AIL5bss"

### `nd`

`nd` argument is a `TRUE` or `FALSE` argument. Data retrieved sometimes
includes ND terms. If `nd` is set to `TRUE` (which is default), all NDs
are converted to NAs.

### `as`

`as` argument is the class of the output. Available classes are;

- **tibble**
- **tsibble**
- **data.frame**
- **data.table**

**tibble** is the default output class.

## Examples

### Single Series

Following example retrieves **(USDTRY) US Dollar (Buying) Exchange
Rate**.

``` r
library(cbRt)
series    <- "TP.DK.USD.A"
start_date <- "01-01-2017"
end_date   <- "01-01-2018"
token     <- Sys.getenv("EVDS_TOKEN")

(usd_try <- cbrt_get(series, start_date, end_date, token = token))
#> # A tibble: 366 × 2
#>    Date       TP_DK_USD_A
#>    <date>           <dbl>
#>  1 2017-01-01       NA   
#>  2 2017-01-02        3.52
#>  3 2017-01-03        3.53
#>  4 2017-01-04        3.57
#>  5 2017-01-05        3.58
#>  6 2017-01-06        3.59
#>  7 2017-01-07       NA   
#>  8 2017-01-08       NA   
#>  9 2017-01-09        3.61
#> 10 2017-01-10        3.70
#> # ℹ 356 more rows
```

### Multiple Series

Following example retrieves multiple different series with different
frequencies.

EDDS API converts series to a common frequency if they are requested
together and no frequency argument is given.

For example, if you request one yearly and one monthly series, API will
return both series as yearly values.

Package, on the other hand, sends independent queries for each series
and joins them together without changing the frequency.

I opted not to include `freq` argument to function call.

The example below also shows the usage of the `formulas` argument.

``` r
start_date <- "01-01-2017"
end_date <- "01-01-2020"
series <- c("TP.AB.B1", "TP.AB.C2", "TP.BKEA.S001", "TP.KB.O06.TRL")
formulas <- c(2, 3, 7, 8)
token <- Sys.getenv("EVDS_TOKEN") # Get token from .Renviron

# data(cbrt_meta_data)
# cbrt_meta_data %>% 
#   dplyr::filter(SERIE_CODE %in% series) %>% 
#   dplyr::select(SERIE_CODE, FREQUENCY_STR)
# 
#      SERIE_CODE  FREQUENCY_STR
# 1      TP.AB.C2 HAFTALIK(CUMA)
# 2      TP.AB.B1          AYLIK
# 3  TP.BKEA.S001       ÜÇ AYLIK
# 4 TP.KB.O06.TRL         YILLIK

# EDDS API returns following
url <- paste0("https://evds2.tcmb.gov.tr/service/evds/series=TP.AB.B1-TP.AB.C2-TP.BKEA.S001-TP.KB.O06.TRL&startDate=01-01-2017&endDate=01-01-2020&type=json", "&formulas=2-3-7-8")

(edds_dat <- cbRt:::cbrt_geturl(url, token = token) %>%
    httr::content(as = "text", encoding = "UTF-8") %>% 
    jsonlite::fromJSON() %>%
    .[["items"]] %>%
    tibble::as_tibble())
#> # A tibble: 4 × 10
#>   Tarih `TP_AB_B1-2` `TP_AB_C2-3`        `TP_BKEA_S001-7` `TP_KB_O06_TRL-8`
#>   <chr> <chr>        <chr>               <chr>            <chr>            
#> 1 2017  9485.7       -8.625746876697447  0                343279699.6      
#> 2 2018  -3407        -14.421590773986445 -20.3            399316709.55     
#> 3 2019  6957         12.864684634620726  57.1             471538564.43     
#> 4 2020  16466        -38.49704579025111  1.2              144592850        
#> # ℹ 5 more variables: UNIXTIME <df[,1]>, TP_AB_B1 <lgl>, TP_AB_C2 <lgl>,
#> #   TP_BKEA_S001 <lgl>, TP_KB_O06_TRL <lgl>
```

**NOTE** that API call returns empty columns. `cbrt_get` function also
removes them.

``` r
(dat <- cbrt_get(series, start_date, end_date, as = "tsibble"))
#> # A tsibble: 188 x 5 [1D]
#>    Date       TP_AB_B1 TP_AB_C2 TP_BKEA_S001 TP_KB_O06_TRL
#>    <date>        <dbl>    <dbl>        <dbl>         <dbl>
#>  1 2017-01-01    15933       NA            0    343279700.
#>  2 2017-01-06       NA    96933           NA           NA 
#>  3 2017-01-13       NA    95292           NA           NA 
#>  4 2017-01-20       NA    92296           NA           NA 
#>  5 2017-01-27       NA    92517           NA           NA 
#>  6 2017-02-01    16648       NA           NA           NA 
#>  7 2017-02-03       NA    91522           NA           NA 
#>  8 2017-02-10       NA    92798           NA           NA 
#>  9 2017-02-17       NA    89049           NA           NA 
#> 10 2017-02-24       NA    91088           NA           NA 
#> # ℹ 178 more rows
```

### Series with Location Data

Following are examples for data with location attributes. Series is
Hedonic House Price Index (HHPI)(2010=100)(CBRT)(Monthly). `TP.HKFE02`
and `TP.HKFE03` are price indices codes for Istanbul and Ankara,
respectively. This series can be used to draw maps. At this time there
is no support in the package though.

``` r
# Single Series
series <- "TP.HKFE02"
(hhpi <- cbrt_get(series, start_date, end_date))
#> # A tibble: 37 × 2
#>    Date       TP_HKFE02
#>    <date>         <dbl>
#>  1 2017-01-01      97.5
#>  2 2017-02-01      98.6
#>  3 2017-03-01      99.4
#>  4 2017-04-01      99.8
#>  5 2017-05-01     100. 
#>  6 2017-06-01     100. 
#>  7 2017-07-01     100. 
#>  8 2017-08-01     100. 
#>  9 2017-09-01     100. 
#> 10 2017-10-01     101. 
#> # ℹ 27 more rows
```

``` r
# Multiple Series
series <- c("TP.HKFE02", "TP.HKFE03")
(hhpi <- cbrt_get(series, start_date, end_date))
#> # A tibble: 37 × 3
#>    Date       TP_HKFE02 TP_HKFE03
#>    <date>         <dbl>     <dbl>
#>  1 2017-01-01      97.5      96.4
#>  2 2017-02-01      98.6      97.3
#>  3 2017-03-01      99.4      98.6
#>  4 2017-04-01      99.8      99.2
#>  5 2017-05-01     100.      100. 
#>  6 2017-06-01     100.      100. 
#>  7 2017-07-01     100.      100. 
#>  8 2017-08-01     100.       99.9
#>  9 2017-09-01     100.      101. 
#> 10 2017-10-01     101.      102. 
#> # ℹ 27 more rows
```
