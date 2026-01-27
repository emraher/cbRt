test_that("cbrt_get requires token", {
  skip_if(Sys.getenv("EVDS_TOKEN") == "", "No EVDS_TOKEN available")

  # Empty token results in 403 error from API
  expect_error(
    cbrt_get(
      series = "TP.DK.USD.A",
      start_date = "01-01-2023",
      end_date = "01-02-2023",
      token = ""
    ),
    "Bad Request|403"
  )
})

test_that("cbrt_get returns correct output types", {
  skip_if(Sys.getenv("EVDS_TOKEN") == "", "No EVDS_TOKEN available")

  # Test tibble output (default)
  result_tibble <- cbrt_get(
    series = "TP.DK.USD.A",
    start_date = "01-01-2023",
    end_date = "05-01-2023",
    as = "tibble"
  )

  expect_s3_class(result_tibble, "tbl_df")
  expect_true("Date" %in% names(result_tibble))

  # Test data.frame output
  result_df <- cbrt_get(
    series = "TP.DK.USD.A",
    start_date = "01-01-2023",
    end_date = "05-01-2023",
    as = "data.frame"
  )

  expect_s3_class(result_df, "data.frame")
  expect_true("Date" %in% names(result_df))

  # Test data.table output
  result_dt <- cbrt_get(
    series = "TP.DK.USD.A",
    start_date = "01-01-2023",
    end_date = "05-01-2023",
    as = "data.table"
  )

  expect_s3_class(result_dt, "data.table")
  expect_true("Date" %in% names(result_dt))
})

test_that("cbrt_get handles ND values", {
  skip_if(Sys.getenv("EVDS_TOKEN") == "", "No EVDS_TOKEN available")

  result <- cbrt_get(
    series = "TP.DK.USD.A",
    start_date = "01-01-2023",
    end_date = "05-01-2023",
    nd = TRUE
  )

  # Check that non-Date columns are numeric (ND converted to NA)
  numeric_cols <- result |> dplyr::select(-Date)
  expect_true(all(sapply(numeric_cols, is.numeric)))
})

test_that("cbrt_get handles multiple series", {
  skip_if(Sys.getenv("EVDS_TOKEN") == "", "No EVDS_TOKEN available")

  result <- cbrt_get(
    series = c("TP.DK.USD.A", "TP.DK.EUR.A"),
    start_date = "01-01-2023",
    end_date = "05-01-2023"
  )

  expect_s3_class(result, "tbl_df")
  expect_true("Date" %in% names(result))
  # Should have Date column plus at least 2 series columns
  expect_gte(ncol(result), 3)
})
