test_that("cbrt_url constructs valid URLs", {
  url <- cbRt:::cbrt_url(
    series = "TP.DK.USD.A",
    token = "test_token",
    start_date = "01-01-2023",
    end_date = "01-01-2024"
  )

  expect_type(url, "character")
  expect_match(url, "^https://evds3.tcmb.gov.tr/igmevdsms-dis/")
  expect_match(url, "series=TP.DK.USD.A")
  expect_match(url, "startDate=01-01-2023")
  expect_match(url, "endDate=01-01-2024")
  expect_match(url, "type=json")
})

test_that("cbrt_url handles multiple series", {
  url <- cbRt:::cbrt_url(
    series = c("TP.DK.USD.A", "TP.DK.EUR.A"),
    token = "test_token",
    start_date = "01-01-2023",
    end_date = "01-01-2024"
  )

  expect_match(url, "series=TP.DK.USD.A-TP.DK.EUR.A")
})

test_that("cbrt_url handles formulas", {
  url <- cbRt:::cbrt_url(
    series = "TP.DK.USD.A",
    token = "test_token",
    start_date = "01-01-2023",
    end_date = "01-01-2024",
    formulas = 3
  )

  expect_match(url, "formulas=3")
})

test_that("cbrt_url requires all parameters", {
  expect_error(
    cbRt:::cbrt_url(start_date = "01-01-2023", end_date = "01-01-2024"),
    "must provide series"
  )

  expect_error(
    cbRt:::cbrt_url(series = "TP.DK.USD.A", end_date = "01-01-2024"),
    "must provide"
  )

  expect_error(
    cbRt:::cbrt_url(series = "TP.DK.USD.A", start_date = "01-01-2023"),
    "must provide"
  )
})
