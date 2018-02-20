
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cbRt

[![Project Status: WIP - Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Linux Build
Status](https://travis-ci.org/emraher/cbRt.svg?branch=master)](https://travis-ci.org/emraher/cbRt)
[![Windows Build
status](https://ci.appveyor.com/api/projects/status/4ejevtp69fcrr31o?svg=true)](https://ci.appveyor.com/project/emraher/cbRt)
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

## Installation

You can install `cbRt` from github with:

``` r
# install.packages("devtools")
devtools::install_github("emraher/cbRt")
```

## Usage and Arguments

There is only one function in the package which retrieves data from
EDDS.

``` r
cbRt_get(series, startDate, endDate, token, 
         aggregationTypes = NULL, formulas = NULL, freq = NULL, nd = TRUE,
         as = c("tibble", "tibbletime", "data.frame", "data.table"))
```

Following are the arguments used in the functions. Descriptions are
taken from [EDDS Web Service Usage
Guide](https://evds2.tcmb.gov.tr/help/videos/EVDS_Web_Service_Usage_Guide.pdf).

**Note that,** `series`**,** `startDate`**,** `endDate`**,** **and**
`token` **are all required arguments.**

### `series`

`series` argument can be obtained from CBRT webpage. [Search CBRT
webpage](https://evds2.tcmb.gov.tr) in order to find out the series code
and use it in the `series` argument. For example, `TP.DK.USD.A` is the
code for **(USDTRY) US Dollar (Buying) Exchange Rate**. Argument can
take multiple values.

### `startDate`

`startDate` argument is the series start date as `dd-mm-yyyy` format. In
order to display the frequency of the desired series, the first day of
the corresponding frequency must be stated in the start date as
`dd-mm-yyyy` format. **This argument takes a single value.**

### `endDate`

`endDate` argument is the series end date as `dd-mm-yyyy` format. **This
argument takes a single value.**

### `token`

`token` argument is the required API key. [Follow the instructions on
CBRT
webpage](https://evds2.tcmb.gov.tr/help/videos/EVDS_Web_Service_Usage_Guide.pdf)
to obtain the user specific API key. **This argument takes a single
value.**

### `aggregationTypes`

`aggregationTypes` argument is the aggregation applied to series.
Available aggregations are;

  - **default** : Original
  - **avg** : Average
  - **min** : Minimum
  - **max** : Maximum
  - **first** : Beginning
  - **last** : End
  - **sum** : Cumulative

If this parameter is not entered by the user, the original observation
parameter is applied for the relevant series. Argument can take multiple
values.

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

If this parameter is not entered by the user, the level formula
parameter is applied for the relevant series. Argument can take multiple
values.

### `freq`

`freq` argument is the frequency of the series. Available frequencies
are;

  - **1**: Daily
  - **2**: Business
  - **3**: Weekly (Friday)
  - **4**: Twicemonthly
  - **5**: Monthly
  - **6**: Quarterly
  - **7**: Semiannual
  - **8**: Annual

If this parameter is not entered by the user, the common frequency of
the series is taken. If you enter a higher frequency (eg: monthly) than
the common frequency of the series (eg: annually), the common frequency
of the series is taken into account (eg: annually). **This argument
takes a single value.**

### `nd`

`nd` argument is a `TRUE` or `FALSE` argument. Data retrieved sometimes
includes ND terms. If `nd` is set to `TRUE` (which is default), all NDs
are converted to NAs.

### `as`

`as` argument is the class of the output. Available classes are;

  - **tibble**
  - **tibbletime**
  - **data.frame**
  - **data.table**

**tibble** is the default output class.

## Examples

### Single Series

Following example retrieves **(USDTRY) US Dollar (Buying) Exchange
Rate**. Since no optional arguments are supplied, default values for the
relevant series are applied. In this case `freq` is `1` (Daily),
`aggregationTypes` is `default` (Original), and `formulas` is `0`
(Level). Compare the data sets retrieved.

``` r
library(cbRt)
series    <- "TP.DK.USD.A"
startDate <- "01-01-2017"
endDate   <- "01-01-2018"
token     <- readLines("token")

(usd_try <- cbRt_get(series, startDate, endDate, token))
#> # A tibble: 366 x 2
#>    Date       TP_DK_USD_A
#>  * <date>           <dbl>
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
#> # ... with 356 more rows
(usd_try <- cbRt_get(series, startDate, endDate, token, aggregationTypes = "default", formulas = 0, freq = 1))
#> # A tibble: 366 x 2
#>    Date       TP_DK_USD_A
#>  * <date>           <dbl>
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
#> # ... with 356 more rows
```

We can get single series with multiple different formulas. In this
example, `formulas` is set to `0` (Level) and `1` (Percentage
Change).

``` r
(usd_try <- cbRt_get(series, startDate, endDate, token, formulas = c(0, 1)))
#> # A tibble: 366 x 3
#>    Date       TP_DK_USD_A `TP_DK_USD_A-1`
#>  * <date>           <dbl>           <dbl>
#>  1 2017-01-01       NA            NA     
#>  2 2017-01-02        3.52         NA     
#>  3 2017-01-03        3.53          0.415 
#>  4 2017-01-04        3.57          1.13  
#>  5 2017-01-05        3.58          0.0756
#>  6 2017-01-06        3.59          0.475 
#>  7 2017-01-07       NA            NA     
#>  8 2017-01-08       NA            NA     
#>  9 2017-01-09        3.61         NA     
#> 10 2017-01-10        3.70          2.45  
#> # ... with 356 more rows
```

**TODO:** Throw error in this case.

We cannot get single series with multiple different aggregation types,
which makes sense. In this example, `aggregationTypes` is set to `avg`
(Average) and `min` (Minimum). Result is daily original
observations.

``` r
(usd_try <- cbRt_get(series, startDate, endDate, token, aggregationTypes = c("avg", "min")))
#> # A tibble: 366 x 2
#>    Date       TP_DK_USD_A
#>  * <date>           <dbl>
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
#> # ... with 356 more rows
```

**TODO:** Gives an extra column. Delete this.

We can get single series with multiple different aggregation types and
multiple different formulas. In the first column `aggregationTypes` is
`min` (Minimum) and `formulas` is `1` (Percentage Change). In the second
column `aggregationTypes` is `max` (Maximum) and `formulas` is `2`
(Difference).

``` r
(usd_try <- cbRt_get(series, startDate, endDate, token, aggregationTypes = c("min", "max"), formulas = c(1, 2)))
#> # A tibble: 366 x 4
#>    Date       `TP_DK_USD_A-1` `TP_DK_USD_A-2` TP_DK_USD_A
#>  * <date>               <dbl>           <dbl>       <dbl>
#>  1 2017-01-01         NA             NA                NA
#>  2 2017-01-02         NA             NA                NA
#>  3 2017-01-03          0.415          0.0146           NA
#>  4 2017-01-04          1.13           0.0399           NA
#>  5 2017-01-05          0.0756         0.00270          NA
#>  6 2017-01-06          0.475          0.0170           NA
#>  7 2017-01-07         NA             NA                NA
#>  8 2017-01-08         NA             NA                NA
#>  9 2017-01-09         NA             NA                NA
#> 10 2017-01-10          2.45           0.0886           NA
#> # ... with 356 more rows
```

### Multiple Series

Following example retrieves **(USDTRY) US Dollar (Buying) Exchange
Rate** and **(EURTRY) Euro (Buying) Exchange Rate**. Since no optional
arguments are supplied, default values for the relevant series are
applied. In this case `freq` is `1` (Daily), `aggregationTypes` is
`default` (Original), and `formualas` is `0` (Level). Compare the data
sets retrieved.

``` r
series <- c("TP.DK.USD.A", "TP.DK.EUR.A")

(usd_eur_try <- cbRt_get(series, startDate, endDate, token))
#> # A tibble: 366 x 3
#>    Date       TP_DK_USD_A TP_DK_EUR_A
#>  * <date>           <dbl>       <dbl>
#>  1 2017-01-01       NA          NA   
#>  2 2017-01-02        3.52        3.71
#>  3 2017-01-03        3.53        3.71
#>  4 2017-01-04        3.57        3.73
#>  5 2017-01-05        3.58        3.73
#>  6 2017-01-06        3.59        3.78
#>  7 2017-01-07       NA          NA   
#>  8 2017-01-08       NA          NA   
#>  9 2017-01-09        3.61        3.83
#> 10 2017-01-10        3.70        3.90
#> # ... with 356 more rows
(usd_eur_try <- cbRt_get(series, startDate, endDate, token, freq = 1, formulas = 0))
#> # A tibble: 366 x 3
#>    Date       TP_DK_USD_A TP_DK_EUR_A
#>  * <date>           <dbl>       <dbl>
#>  1 2017-01-01       NA          NA   
#>  2 2017-01-02        3.52        3.71
#>  3 2017-01-03        3.53        3.71
#>  4 2017-01-04        3.57        3.73
#>  5 2017-01-05        3.58        3.73
#>  6 2017-01-06        3.59        3.78
#>  7 2017-01-07       NA          NA   
#>  8 2017-01-08       NA          NA   
#>  9 2017-01-09        3.61        3.83
#> 10 2017-01-10        3.70        3.90
#> # ... with 356 more rows
```

**TODO:** Gives an extra column. Delete this.

We can get multiple series with multiple different formulas. In this
example, `formulas` is set to `0` (Level) and `1` (Percentage
Change).

``` r
(usd_eur_try <- cbRt_get(series, startDate, endDate, token, formulas = c(0, 1)))
#> # A tibble: 366 x 4
#>    Date       TP_DK_USD_A `TP_DK_EUR_A-1` TP_DK_EUR_A
#>  * <date>           <dbl>           <dbl>       <dbl>
#>  1 2017-01-01       NA            NA               NA
#>  2 2017-01-02        3.52         NA               NA
#>  3 2017-01-03        3.53        - 0.0350          NA
#>  4 2017-01-04        3.57          0.518           NA
#>  5 2017-01-05        3.58          0.0349          NA
#>  6 2017-01-06        3.59          1.39            NA
#>  7 2017-01-07       NA            NA               NA
#>  8 2017-01-08       NA            NA               NA
#>  9 2017-01-09        3.61         NA               NA
#> 10 2017-01-10        3.70          1.87            NA
#> # ... with 356 more rows
```

**TODO:** Throw error in this case.

We cannot get multiple series with multiple different aggregation types.
In this example, `aggregationTypes` is set to `avg` (Average) and `min`
(Minimum). Result is daily original
observations.

``` r
(usd_eur_try <- cbRt_get(series, startDate, endDate, token, aggregationTypes = c("avg", "min")))
#> # A tibble: 366 x 3
#>    Date       TP_DK_USD_A TP_DK_EUR_A
#>  * <date>           <dbl>       <dbl>
#>  1 2017-01-01       NA          NA   
#>  2 2017-01-02        3.52        3.71
#>  3 2017-01-03        3.53        3.71
#>  4 2017-01-04        3.57        3.73
#>  5 2017-01-05        3.58        3.73
#>  6 2017-01-06        3.59        3.78
#>  7 2017-01-07       NA          NA   
#>  8 2017-01-08       NA          NA   
#>  9 2017-01-09        3.61        3.83
#> 10 2017-01-10        3.70        3.90
#> # ... with 356 more rows
```

**TODO:** Gives an extra column. Delete this.

We can get multiple series with multiple different aggregation types and
multiple different formulas. In the first column `aggregationTypes` is
`avg` (Average) and `formulas` is `0` (Level). In the second column
`aggregationTypes` is `min` (Minimum) and `formulas` is `1` (Percentage
Change).

``` r
(usd_eur_try <- cbRt_get(series, startDate, endDate, token, 
                        aggregationTypes = c("avg", "min"), formulas = c(0, 1)))
#> # A tibble: 366 x 4
#>    Date       TP_DK_USD_A `TP_DK_EUR_A-1` TP_DK_EUR_A
#>  * <date>           <dbl>           <dbl>       <dbl>
#>  1 2017-01-01       NA            NA               NA
#>  2 2017-01-02        3.52         NA               NA
#>  3 2017-01-03        3.53        - 0.0350          NA
#>  4 2017-01-04        3.57          0.518           NA
#>  5 2017-01-05        3.58          0.0349          NA
#>  6 2017-01-06        3.59          1.39            NA
#>  7 2017-01-07       NA            NA               NA
#>  8 2017-01-08       NA            NA               NA
#>  9 2017-01-09        3.61         NA               NA
#> 10 2017-01-10        3.70          1.87            NA
#> # ... with 356 more rows
```

We can get multiple series with multiple different aggregation types and
multiple different formulas. In the first column `aggregationTypes` is
`avg` (Average) and `formulas` is `0` (Level). In the second column
`aggregationTypes` is `min` (Minimum) and `formulas` is `1` (Percentage
Change). We also set `freq` to `5` (Monthly).

``` r
(usd_eur_try <- cbRt_get(series, startDate, endDate, token, 
                        aggregationTypes = c("avg", "min"), formulas = c(0, 1), freq = 5))
#> # A tibble: 13 x 4
#>    Date       TP_DK_USD_A `TP_DK_EUR_A-1` TP_DK_EUR_A
#>  * <date>           <dbl>           <dbl>       <dbl>
#>  1 2017-01-01        3.73           2.15           NA
#>  2 2017-02-01        3.67           1.71           NA
#>  3 2017-03-01        3.67           1.33           NA
#>  4 2017-04-01        3.65           1.48           NA
#>  5 2017-05-01        3.56          -0.621          NA
#>  6 2017-06-01        3.52           1.44           NA
#>  7 2017-07-01        3.56           2.62           NA
#>  8 2017-08-01        3.51           2.23           NA
#>  9 2017-09-01        3.47          -0.548          NA
#> 10 2017-10-01        3.66           2.76           NA
#> 11 2017-11-01        3.88           4.81           NA
#> 12 2017-12-01        3.85           2.60           NA
#> 13 2018-01-01        3.77           0.153          NA
```

### Series with Location Data

Following are examples for data with location attributes. Series is
Hedonic House Price Index (HHPI)(2010=100)(CBRT)(Monthly). `TP.HKFE02`
and `TP.HKFE03` are price indices codes for Ankara and Istanbul,
respectively. This series can be used to draw maps. At this time there
is no support in the package though.

``` r
# Single Series
series <- "TP.HKFE02"
(hhpi <- cbRt_get(series, startDate, endDate, token))
#> # A tibble: 11 x 2
#>    Date       TP_HKFE02
#>  * <date>         <dbl>
#>  1 2017-01-01       254
#>  2 2017-02-01       257
#>  3 2017-03-01       259
#>  4 2017-04-01       260
#>  5 2017-05-01       263
#>  6 2017-06-01       263
#>  7 2017-07-01       263
#>  8 2017-08-01       263
#>  9 2017-09-01       263
#> 10 2017-10-01       266
#> 11 2017-11-01       265
```

``` r
# Multiple Series
series <- c("TP.HKFE02", "TP.HKFE03")
(hhpi <- cbRt_get(series, startDate, endDate, token))
#> # A tibble: 11 x 3
#>    Date       TP_HKFE02 TP_HKFE03
#>  * <date>         <dbl>     <dbl>
#>  1 2017-01-01       254       181
#>  2 2017-02-01       257       182
#>  3 2017-03-01       259       184
#>  4 2017-04-01       260       185
#>  5 2017-05-01       263       187
#>  6 2017-06-01       263       188
#>  7 2017-07-01       263       188
#>  8 2017-08-01       263       188
#>  9 2017-09-01       263       189
#> 10 2017-10-01       266       190
#> 11 2017-11-01       265       191
```
