test_that("check_formulas validates formula codes", {
  # Valid formulas (0-8)
  expect_type(cbRt:::check_formulas("TP.DK.USD.A", 0), "character")
  expect_type(cbRt:::check_formulas("TP.DK.USD.A", 3), "character")
  expect_type(cbRt:::check_formulas("TP.DK.USD.A", 8), "character")

  # NULL formulas should return empty string
  expect_equal(cbRt:::check_formulas("TP.DK.USD.A", NULL), "")

  # Invalid formulas
  expect_error(
    cbRt:::check_formulas("TP.DK.USD.A", 9),
    "formulas must be either"
  )

  expect_error(
    cbRt:::check_formulas("TP.DK.USD.A", -1),
    "formulas must be either"
  )
})

test_that("check_formulas handles multiple formulas", {
  result <- cbRt:::check_formulas("TP.DK.USD.A", c(0, 3, 5))

  expect_type(result, "character")
  expect_match(result, "formulas=0-3-5")
})

test_that("check_formulas returns correct format", {
  result <- cbRt:::check_formulas("TP.DK.USD.A", 3)

  expect_match(result, "^&formulas=")
  expect_match(result, "3$")
})
