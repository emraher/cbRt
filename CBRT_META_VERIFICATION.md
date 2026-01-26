# cbrt_meta Function Verification

## Summary

The `cbrt_meta()` function has been tested and verified to be working properly.

## Test Results

### Execution Date
2026-01-27

### Test Output
```
SUCCESS: cbrt_meta() executed without errors
  Rows returned: 47,370
  Columns returned: 28
```

### Data Structure Verification

All expected columns are present:
- ✓ DATAGROUP_CODE
- ✓ SERIE_CODE
- ✓ SERIE_NAME_ENG
- ✓ FREQUENCY_STR
- ✓ START_DATE
- ✓ END_DATE

Plus 22 additional metadata columns including:
- DEFAULT_AGG_METHOD_STR
- TAG, TAG_ENG
- DATASOURCE, DATASOURCE_ENG
- METADATA_LINK, REV_POL_LINK, APP_CHA_LINK
- And more...

### Functional Tests

1. **Basic Execution**: ✓ Function executes without errors
2. **Data Retrieval**: ✓ Returns 47,370 series from CBRT EVDS API v3
3. **Search Functionality**: ✓ Data can be filtered and searched
4. **Known Series**: ✓ Common series like TP.DK.USD.A and TP.DK.EUR.A are present

## Improvements Made

### 1. Fixed Documentation
- **Before**: Example used `cbRt_meta` (incorrect casing)
- **After**: Example uses `cbrt_meta` (correct function name)
- **Added**: `@return` documentation

### 2. Added Error Handling
- **New**: Check if token is empty and provide helpful error message
- **Before**: Would fail with cryptic HTTP error if no token provided
- **After**: Clear error: "API token not found. Please provide a token or set EVDS_TOKEN environment variable."

### 3. Code Cleanup
- **Removed**: Unused join with categories data (was joined but never used in output)
- **Simplified**: Function now has clearer, more direct logic

## Function Flow

```
cbrt_meta(token)
    ↓
1. Check token (get from env if not provided)
    ↓
2. Validate token (error if empty)
    ↓
3. Get all categories from API
    ↓
4. Get all data groups from API
    ↓
5. For each data group, get series info
    ↓
6. Combine all series info into single data frame
    ↓
7. Return metadata (47,370 rows × 28 columns)
```

## Sample Usage

### Basic Usage
```r
library(cbRt)

# With token from environment
metadata <- cbrt_meta()

# With explicit token
metadata <- cbrt_meta(token = "your_api_key")
```

### Search for Exchange Rates
```r
library(dplyr)

metadata %>%
  filter(grepl("exchange|currency", SERIE_NAME_ENG, ignore.case = TRUE)) %>%
  select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR, START_DATE, END_DATE)
```

### Find Specific Series
```r
metadata %>%
  filter(SERIE_CODE == "TP.DK.USD.A") %>%
  select(SERIE_CODE, SERIE_NAME_ENG, FREQUENCY_STR, START_DATE, END_DATE)
```

## Testing

A comprehensive test script is available: `test_cbrt_meta.R`

Run it with:
```r
source("test_cbrt_meta.R")
```

Or from command line:
```bash
Rscript test_cbrt_meta.R
```

The test script performs:
1. Basic function call test
2. Data structure verification
3. Data presence check
4. Search functionality test
5. Known series verification

## Known Issues

None identified. Function is working as expected.

## Performance Notes

- Execution time: ~10-30 seconds (depends on API response time)
- Network calls: ~100+ API requests (one per data group)
- Data size: ~47,370 series with 28 metadata fields each
- Memory: Moderate (result is ~2-3 MB)

## Recommendations

1. **Cache Results**: For applications that need metadata frequently, consider caching the result to avoid repeated API calls
2. **Subset Early**: If you only need specific categories, consider using the lower-level helper functions directly
3. **Error Handling**: When using in production, wrap calls in `tryCatch()` to handle network errors gracefully

## Related Functions

- `get_categories_info(token)` - Get category information
- `get_groups_info(token, category_id)` - Get data groups
- `get_series_info(token, code)` - Get series for a specific data group
- `cbrt_get()` - Retrieve actual time series data

## Conclusion

The `cbrt_meta()` function is working correctly and is ready for use. All improvements have been made and tests pass successfully.
