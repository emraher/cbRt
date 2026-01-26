#!/usr/bin/env Rscript
# Manual test script for cbrt_meta function
# Run this with: Rscript test_cbrt_meta.R
# or in R: source("test_cbrt_meta.R")

library(cbRt)
library(dplyr)

cat(paste(rep("=", 70), collapse = ""), "\n")
cat("Testing cbrt_meta function\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

# Check if token is available
token <- Sys.getenv("EVDS_TOKEN")
if (token == "") {
  cat("ERROR: EVDS_TOKEN not found in environment.\n")
  cat("Please set it with: Sys.setenv(EVDS_TOKEN = 'your_token_here')\n")
  cat("Or add it to your .Renviron file.\n\n")

  cat("Testing with bundled data instead...\n\n")
  data(cbrt_meta_data, package = "cbRt")

  cat("Loaded cbrt_meta_data:\n")
  cat("  Rows:", nrow(cbrt_meta_data), "\n")
  cat("  Columns:", ncol(cbrt_meta_data), "\n")
  cat("  Column names:", paste(names(cbrt_meta_data), collapse = ", "), "\n\n")

  cat("Sample of data:\n")
  print(head(cbrt_meta_data, 3))

  cat("\n\nTo test the live API function, set EVDS_TOKEN and re-run this script.\n")
  quit(status = 0)
}

cat("Token found. Testing cbrt_meta() with live API...\n\n")

# Test 1: Basic function call
cat("Test 1: Basic function call\n")
cat(paste(rep("-", 70), collapse = ""), "\n")

tryCatch({
  result <- cbrt_meta(token = token)

  cat("SUCCESS: cbrt_meta() executed without errors\n")
  cat("  Rows returned:", nrow(result), "\n")
  cat("  Columns returned:", ncol(result), "\n")
  cat("  Column names:", paste(names(result), collapse = ", "), "\n\n")

  # Test 2: Check data structure
  cat("Test 2: Verify data structure\n")
  cat(paste(rep("-", 70), collapse = ""), "\n")

  expected_cols <- c("DATAGROUP_CODE", "SERIE_CODE", "SERIE_NAME_ENG",
                     "FREQUENCY_STR", "START_DATE", "END_DATE")

  missing_cols <- setdiff(expected_cols, names(result))
  if (length(missing_cols) > 0) {
    cat("WARNING: Missing expected columns:", paste(missing_cols, collapse = ", "), "\n")
  } else {
    cat("SUCCESS: All expected columns present\n")
  }

  # Test 3: Check for data
  cat("\nTest 3: Check for actual data\n")
  cat(paste(rep("-", 70), collapse = ""), "\n")

  if (nrow(result) == 0) {
    cat("ERROR: No data returned\n")
  } else {
    cat("SUCCESS: Data returned (", nrow(result), "series)\n")
    cat("\nSample of data:\n")
    print(head(result %>% select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR, START_DATE), 5))
  }

  # Test 4: Search functionality
  cat("\n\nTest 4: Test search functionality\n")
  cat(paste(rep("-", 70), collapse = ""), "\n")

  # Search for USD exchange rate series
  usd_series <- result %>%
    filter(grepl("USD", SERIE_CODE, ignore.case = TRUE)) %>%
    filter(grepl("exchange|currency|döviz", SERIE_NAME_ENG, ignore.case = TRUE)) %>%
    select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR, START_DATE, END_DATE) %>%
    head(10)

  if (nrow(usd_series) > 0) {
    cat("SUCCESS: Found", nrow(usd_series), "USD-related series\n")
    cat("\nSample USD series:\n")
    print(usd_series)
  } else {
    cat("WARNING: No USD series found in metadata\n")
  }

  # Test 5: Check for common test series
  cat("\n\nTest 5: Verify known series exist\n")
  cat(paste(rep("-", 70), collapse = ""), "\n")

  test_series <- c("TP.DK.USD.A", "TP.DK.EUR.A")
  found_series <- result %>%
    filter(SERIE_CODE %in% test_series) %>%
    select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR)

  if (nrow(found_series) == length(test_series)) {
    cat("SUCCESS: All test series found\n")
    print(found_series)
  } else {
    cat("WARNING: Not all test series found\n")
    cat("Expected:", paste(test_series, collapse = ", "), "\n")
    cat("Found:", paste(found_series$SERIE_CODE, collapse = ", "), "\n")
  }

  cat("\n")
  cat(paste(rep("=", 70), collapse = ""), "\n")
  cat("All tests completed successfully!\n")
  cat(paste(rep("=", 70), collapse = ""), "\n")

}, error = function(e) {
  cat("ERROR: cbrt_meta() failed with error:\n")
  cat("  ", conditionMessage(e), "\n\n")

  cat("Debugging information:\n")
  cat("  Token length:", nchar(token), "\n")
  cat("  Token (first 10 chars):", substr(token, 1, 10), "...\n")

  cat("\nTraceback:\n")
  traceback()
})
