# Installing the bcpredict Package

The package has been successfully built and installed on your system. However, if you encounter the same error again in RStudio, follow these steps.

## Why the Error Occurred

The command `install.packages("bcpredict", repos = NULL, type = "source")` fails because:

1. **Rtools warning**: Rtools is required to compile packages from source on Windows. If Rtools is not installed, you will see the warning. However, the package is already built (no compilation needed) because it contains only R code and data. The warning can be ignored if you install from a pre‑built tarball.

2. **Invalid package name**: `install.packages` expects either a CRAN package name or a **path to a source tarball** (`.tar.gz`). Passing `"bcpredict"` without a path makes R look for a package named “bcpredict” on CRAN, which does not exist, causing the “invalid package” error.

## Correct Installation Methods

### Method 1: Install from the existing tarball (recommended)

A tarball `bcpredict_0.1.0.tar.gz` has already been created in the project root. In R or RStudio, run:

```r
install.packages("./bcpredict_0.1.0.tar.gz", repos = NULL, type = "source")
```

If you are in a different directory, adjust the path accordingly.

### Method 2: Use `devtools`

If you have the `devtools` package installed, you can install directly from the source folder:

```r
devtools::install_local("bcpredict")
```

### Method 3: Use `R CMD INSTALL` from the terminal

Open a terminal in the project directory and run:

```bash
R CMD INSTALL bcpredict_0.1.0.tar.gz
```

## Verify Installation

After installation, test the package with:

```r
library(bcpredict)
data(toy_data_features)
predict_diagnosis(toy_data_features)
```

If you see predictions (B/M), the package is working.

## Notes

- The package is already installed in your library (`C:/Users/HP/AppData/Local/R/win-library/4.4/`). You can load it immediately with `library(bcpredict)`.
- If you still see the Rtools warning, you can download and install Rtools from [https://cran.rstudio.com/bin/windows/Rtools/](https://cran.rstudio.com/bin/windows/Rtools/). This is only necessary if you plan to build other packages from source in the future.

## Troubleshooting

If you get an error about missing dependencies (`caret`, `glmnet`, etc.), install them first:

```r
install.packages(c("caret", "glmnet", "Matrix", "pROC", "dplyr"))
```

These dependencies are listed in the DESCRIPTION file and should be installed automatically when using `install.packages` with `dependencies = TRUE`. If not, install them manually.

## Conclusion

The package is ready for use. You can now call `predict_diagnosis()` on new data frames with the required 30 features.