
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cbRt

[![Project Status: WIP - Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Linux Build
Status](https://travis-ci.org/emraher/cbRt.svg?branch=master)](https://travis-ci.org/emraher/cbRt)
[![Windows Build
status](https://ci.appveyor.com/api/projects/status/i4g4anmhv22t959x?svg=true)](https://ci.appveyor.com/project/emraher/cbRt)
[![](http://www.r-pkg.org/badges/version/cbRt)](http://www.r-pkg.org/pkg/cbRt)
[![CRAN RStudio mirror
downloads](http://cranlogs.r-pkg.org/badges/cbRt)](http://www.r-pkg.org/pkg/cbRt)
[![Coverage
status](https://codecov.io/gh/emraher/cbRt/branch/master/graph/badge.svg)](https://codecov.io/github/emraher/cbRt?branch=master)

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

-   See [etaymaz/CBRT](https://github.com/etaymaz/CBRT)

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
One can search this tibble to find series IDs.

The other function is `cbrt_get` which retrieves data from EDDS.

``` r
cbrt_get(series, start_date, end_date, token = NULL, nd = TRUE,
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
code for **(USDTRY) US Dollar (Buying) Exchange Rate**. Argument can
take multiple values.

### `start_date`

`start_date` argument is the series start date as `dd-mm-yyyy` format.
In order to display the frequency of the desired series, the first day
of the corresponding frequency must be stated in the start date as
`dd-mm-yyyy` format. **This argument takes a single value.**

### `end_date`

`end_date` argument is the series end date as `dd-mm-yyyy` format.
**This argument takes a single value.**

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

-   **tibble**
-   **tsibble**
-   **data.frame**
-   **data.table**

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

(usd_try <- cbrt_get(series, start_date, end_date, token))
#> # A tibble: 366 x 2
#>    Date       TP_DK_USD_A
#>    <date>     <chr>      
#>  1 2017-01-01 <NA>       
#>  2 2017-01-02 3.5192     
#>  3 2017-01-03 3.5338     
#>  4 2017-01-04 3.5737     
#>  5 2017-01-05 3.5764     
#>  6 2017-01-06 3.5934     
#>  7 2017-01-07 <NA>       
#>  8 2017-01-08 <NA>       
#>  9 2017-01-09 3.6134     
#> 10 2017-01-10 3.702      
#> # … with 356 more rows
```

### Multiple Series

Following example retrieves **(USDTRY) US Dollar (Buying) Exchange
Rate** and **(EURTRY) Euro (Buying) Exchange Rate**.

``` r
series <- c("TP.DK.USD.A", "TP.DK.EUR.A")

(usd_eur_try <- cbrt_get(series, start_date, end_date, token))
#> # A tibble: 366 x 3
#>    Date       TP_DK_USD_A TP_DK_EUR_A
#>    <date>     <chr>       <chr>      
#>  1 2017-01-01 <NA>        <NA>       
#>  2 2017-01-02 3.5192      3.7099     
#>  3 2017-01-03 3.5338      3.7086     
#>  4 2017-01-04 3.5737      3.7278     
#>  5 2017-01-05 3.5764      3.7291     
#>  6 2017-01-06 3.5934      3.7808     
#>  7 2017-01-07 <NA>        <NA>       
#>  8 2017-01-08 <NA>        <NA>       
#>  9 2017-01-09 3.6134      3.827      
#> 10 2017-01-10 3.702       3.8986     
#> # … with 356 more rows
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
(hhpi <- cbrt_get(series, start_date, end_date, token))
#> # A tibble: 13 x 2
#>    Date       TP_HKFE02
#>    <date>     <chr>    
#>  1 2017-01-01 97.5     
#>  2 2017-02-01 98.6     
#>  3 2017-03-01 99.4     
#>  4 2017-04-01 99.8     
#>  5 2017-05-01 100.4    
#>  6 2017-06-01 100.5    
#>  7 2017-07-01 100.4    
#>  8 2017-08-01 100.2    
#>  9 2017-09-01 100.5    
#> 10 2017-10-01 100.8    
#> 11 2017-11-01 100.7    
#> 12 2017-12-01 101.1    
#> 13 2018-01-01 101
```

``` r
# Multiple Series
series <- c("TP.HKFE02", "TP.HKFE03")
(hhpi <- cbrt_get(series, start_date, end_date, token))
#> # A tibble: 13 x 3
#>    Date       TP_HKFE02 TP_HKFE03
#>    <date>     <chr>     <chr>    
#>  1 2017-01-01 97.5      96.4     
#>  2 2017-02-01 98.6      97.3     
#>  3 2017-03-01 99.4      98.6     
#>  4 2017-04-01 99.8      99.2     
#>  5 2017-05-01 100.4     100.5    
#>  6 2017-06-01 100.5     100.4    
#>  7 2017-07-01 100.4     100.2    
#>  8 2017-08-01 100.2     99.9     
#>  9 2017-09-01 100.5     100.8    
#> 10 2017-10-01 100.8     101.7    
#> 11 2017-11-01 100.7     102.3    
#> 12 2017-12-01 101.1     102.6    
#> 13 2018-01-01 101       102.8
```
