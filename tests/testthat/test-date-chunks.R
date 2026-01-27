test_that("calculate_date_chunks works for small ranges", {
  chunks <- cbRt:::calculate_date_chunks(
    start_date = "01-01-2023",
    end_date = "31-01-2023",
    frequency_code = 5  # Monthly
  )

  expect_s3_class(chunks, "data.frame")
  expect_equal(nrow(chunks), 1)
  expect_equal(chunks$chunk_start, "01-01-2023")
  expect_equal(chunks$chunk_end, "31-01-2023")
})

test_that("calculate_date_chunks splits large ranges", {
  # Daily data for 200 days should require chunking
  chunks <- cbRt:::calculate_date_chunks(
    start_date = "01-01-2023",
    end_date = "31-12-2023",
    frequency_code = 1  # Daily
  )

  expect_s3_class(chunks, "data.frame")
  expect_gt(nrow(chunks), 1)
  expect_true(all(c("chunk_start", "chunk_end") %in% names(chunks)))
})

test_that("calculate_date_chunks handles different frequencies", {
  # Annual data shouldn't need chunking for reasonable ranges
  chunks_annual <- cbRt:::calculate_date_chunks(
    start_date = "01-01-2000",
    end_date = "31-12-2023",
    frequency_code = 8  # Annual
  )

  expect_equal(nrow(chunks_annual), 1)

  # Daily data for same range should need many chunks
  chunks_daily <- cbRt:::calculate_date_chunks(
    start_date = "01-01-2023",
    end_date = "31-12-2023",
    frequency_code = 1  # Daily
  )

  expect_gt(nrow(chunks_daily), 1)
})

test_that("calculate_date_chunks validates dates", {
  expect_error(
    cbRt:::calculate_date_chunks(
      start_date = "invalid",
      end_date = "01-01-2024",
      frequency_code = 1
    ),
    "Invalid date format"
  )

  expect_error(
    cbRt:::calculate_date_chunks(
      start_date = "01-01-2024",
      end_date = "01-01-2023",
      frequency_code = 1
    ),
    "Start date must be before end date"
  )
})
