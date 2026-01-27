test_that("cbrt_meta requires token", {
  expect_error(
    cbrt_meta(token = ""),
    "API token not found"
  )
})

test_that("cbrt_meta returns data frame with expected columns", {
  skip_if(Sys.getenv("EVDS_TOKEN") == "", "No EVDS_TOKEN available")

  result <- cbrt_meta()

  expect_s3_class(result, "data.frame")
  expect_true("SERIE_CODE" %in% names(result))
  expect_true("SERIE_NAME_ENG" %in% names(result))
  expect_true("FREQUENCY_STR" %in% names(result))
  expect_true("START_DATE" %in% names(result))
  expect_true("END_DATE" %in% names(result))
  expect_gt(nrow(result), 0)
})

test_that("bundled cbrt_meta_data is available", {
  data("cbrt_meta_data", package = "cbRt")

  expect_s3_class(cbrt_meta_data, "data.frame")
  expect_true("SERIE_CODE" %in% names(cbrt_meta_data))
  expect_true("SERIE_NAME_ENG" %in% names(cbrt_meta_data))
  expect_gt(nrow(cbrt_meta_data), 0)
})
