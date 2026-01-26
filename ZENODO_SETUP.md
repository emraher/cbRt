# Getting a DOI for cbRt via Zenodo

This guide walks you through getting a DOI for the cbRt package using
Zenodo’s GitHub integration.

## Prerequisites

GitHub repository: <https://github.com/emraher/cbRt>

CITATION.cff file (updated)

inst/CITATION file (created)

.zenodo.json file (created)

## Step-by-Step Instructions

### 1. Enable Zenodo-GitHub Integration

1.  Go to [Zenodo](https://zenodo.org/) (use production Zenodo, not
    sandbox)
2.  Click “Log in” in the top right
3.  Choose “Log in with GitHub”
4.  Authorize Zenodo to access your GitHub account
5.  Once logged in, click your username (top right) → “GitHub”
6.  You’ll see a list of your repositories
7.  Find `emraher/cbRt` and flip the switch to **ON**

### 2. Create a GitHub Release

Before creating the release, commit the changes made:

``` bash
git add CITATION.cff inst/CITATION .zenodo.json .Rbuildignore
git commit -m "Add Zenodo integration and citation files"
git push origin main
```

Now create a tagged release:

``` bash
# Create and push the v0.3.0 tag
git tag -a v0.3.0 -m "Release version 0.3.0 - EVDS API v3 support"
git push origin v0.3.0
```

Then on GitHub:

1.  Go to <https://github.com/emraher/cbRt/releases>
2.  Click “Draft a new release”
3.  Choose tag: `v0.3.0` (the tag you just pushed)
4.  Release title: `cbRt v0.3.0`
5.  Description (example):

``` markdown
## cbRt v0.3.0

First archived release with DOI via Zenodo.

### Major Changes

- Updated to EVDS API v3 with automatic chunking for 150 observation limit
- Hybrid frequency detection with metadata fallback
- Enhanced package infrastructure following modern R package standards

See NEWS.md for full changelog.
```

6.  Click “Publish release”

### 3. Zenodo Will Automatically Archive

Within a few minutes:

- Zenodo will detect the new GitHub release
- Archive the repository snapshot
- Mint TWO DOIs:
  - **Version-specific DOI** (for v0.3.0 specifically)
  - **Concept DOI** (always points to latest version)

### 4. Find Your DOIs

1.  Go to <https://zenodo.org/>
2.  Click your username → “Uploads”
3.  Find the cbRt entry
4.  You’ll see both DOIs listed

The DOI format will be something like: - Concept DOI:
`10.5281/zenodo.XXXXXXX` - Version DOI: `10.5281/zenodo.XXXXXXX+1`

### 5. Update Your Files with the DOI

Once you have the DOIs, update these files:

#### Update CITATION.cff

Add these lines after the `date-released` field:

``` yaml
doi: 10.5281/zenodo.XXXXXXX  # Use the CONCEPT DOI here
```

#### Update inst/CITATION

Add `doi` field to the bibentry:

``` r
bibentry(
  bibtype  = "Manual",
  title    = "cbRt: R Interface to EDDS of CBRT",
  author   = person("Emrah", "Er", email = "eer@eremrah.com",
                    comment = c(ORCID = "0000-0001-9909-7479")),
  year     = 2026,
  note     = "R package version 0.3.0",
  url      = "https://eremrah.com/cbRt/",
  doi      = "10.5281/zenodo.XXXXXXX",  # Concept DOI
  textVersion = paste(
    "Er, E. (2026).",
    "cbRt: R Interface to EDDS of CBRT.",
    "R package version 0.3.0.",
    "https://doi.org/10.5281/zenodo.XXXXXXX"
  )
)
```

#### Update README.Rmd

Add a DOI badge after the existing badges:

``` markdown
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)
```

Then regenerate README.md:

``` r
rmarkdown::render("README.Rmd")
```

### 6. Commit and Push Updates

``` bash
git add CITATION.cff inst/CITATION README.Rmd README.md
git commit -m "Add Zenodo DOI to citation files and README"
git push origin main
```

## Future Releases

For future releases (e.g., v0.4.0):

1.  Update version in DESCRIPTION, CITATION.cff, NEWS.md
2.  Commit changes
3.  Create new git tag: `git tag -a v0.4.0 -m "Release version 0.4.0"`
4.  Push tag: `git push origin v0.4.0`
5.  Create GitHub release (as above)
6.  Zenodo will automatically create a NEW version-specific DOI
7.  The concept DOI remains the same (always points to latest)

## Citation Guidance

Instruct users to cite as follows:

### For general citation (recommended for most papers):

Use the **concept DOI** - this always resolves to the latest version.

    Er, E. (2026). cbRt: R Interface to EDDS of CBRT.
    R package version 0.3.0. https://doi.org/10.5281/zenodo.XXXXXXX

### For reproducibility (when exact version matters):

Use the **version-specific DOI**:

    Er, E. (2026). cbRt: R Interface to EDDS of CBRT (Version 0.3.0).
    Zenodo. https://doi.org/10.5281/zenodo.XXXXXXX+1

## Testing Your Setup

Before creating the release, you can test on Zenodo Sandbox:

1.  Go to <https://sandbox.zenodo.org/>
2.  Follow the same steps
3.  Create a test release with tag like `v0.3.0-test`
4.  Verify the DOI gets minted
5.  Delete the sandbox record and test release
6.  Proceed with production Zenodo

## Troubleshooting

**Zenodo didn’t archive my release:** - Check that the repository toggle
is ON in Zenodo’s GitHub settings - Make sure you created a “Release” on
GitHub, not just a tag - Wait 5-10 minutes; sometimes there’s a delay

**I want to delete a DOI:** - You cannot delete published DOIs (they’re
permanent identifiers) - You can mark them as “newer version available”
on Zenodo

**I made a mistake in .zenodo.json:** - You can edit metadata on
Zenodo’s website after publication - Future releases will use the
updated .zenodo.json

## References

- [Zenodo GitHub
  Guide](https://docs.github.com/en/repositories/archiving-a-github-repository/referencing-and-citing-content)
- [Citation File Format (CFF)](https://citation-file-format.github.io/)
- [Writing R Extensions -
  CITATION](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#CITATION-files)
