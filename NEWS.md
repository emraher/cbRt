# cbRt 0.3.0

## Major Changes

* **BREAKING: Updated to EVDS API v3** - The package now uses the new EVDS API v3 endpoint (`https://evds3.tcmb.gov.tr/igmevdsms-dis/`). All previous API v2 endpoints have been updated.

## New Features

* **Automatic chunking for large date ranges** - The new EVDS API v3 has a 150 observation limit per request. The package now automatically:
  - Detects series frequency from metadata (with fallback to daily frequency)
  - Splits large date ranges into chunks of maximum 150 observations
  - Fetches data in multiple requests when necessary
  - Combines chunks transparently for the user
  - Provides informative messages when chunking occurs

* **Hybrid frequency detection** - Added `get_series_frequency()` helper function that attempts to retrieve series frequency from metadata API, falling back to conservative daily frequency if detection fails.

* **Smart date chunking** - Added `calculate_date_chunks()` helper function that intelligently splits date ranges based on series frequency (daily, business days, weekly, bi-monthly, monthly, quarterly, semi-annual, yearly).

## Documentation Updates

* Updated all documentation to reflect new API v3 endpoints
* Added comprehensive documentation about the 150 observation limit and automatic chunking behavior
* Updated README with new API URLs and references
* Added comprehensive "Getting Started" vignette with practical examples
* Enhanced pkgdown website configuration with eerdown template
* Added package-level documentation (`?cbRt-package`)

## Package Infrastructure

* Updated to modern R package standards following rpkg-template
* Added ORCID identifier for author in DESCRIPTION
* Configured package to use eerdown custom pkgdown template
* Enhanced GitHub Actions workflows (R-CMD-check, test-coverage, pkgdown)
* Added community files: CONTRIBUTING.md, PR template, issue templates
* Added dependabot configuration for automated dependency updates
* Added .lintr configuration for code quality checks
* Added CITATION.cff for modern citation format
* Updated .Rbuildignore and .gitignore to template standards

## Notes

* This update maintains backward compatibility at the package function level - all function signatures remain the same
* Users may notice slightly slower performance for large date ranges due to multiple API requests
* The chunking happens transparently; no changes to user code are required

# cbRt 0.2.0

Previous version (details not documented)
