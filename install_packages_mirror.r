# =============================================================================
# NEOTREE SAMPLE MAKER -- Package Installer (internal mirror)
# =============================================================================
# PURPOSE:
#   Installs the optional CRAN packages from an internal package mirror that
#   requires a bearer token, and checks that each one loads.
#
# INPUTS:
#   MIRROR_REPO   address of the package mirror
#   MIRROR_TOKEN  personal access token for the mirror
#   Set both below before running.  Do not share a copy of this file that
#   contains a token.
#
# OUTPUTS:
#   Installed packages in the R library, and a status listing on the console.
#
# USAGE (from the sample maker root):
#   Rscript install_packages_mirror.r
# =============================================================================

MIRROR_REPO  <- "YOUR_MIRROR_ADDRESS_HERE"
MIRROR_TOKEN <- "YOUR_TOKEN_HERE"

required_packages <- c(
  "rstudioapi",  # Interactive script-path detection (optional, RStudio only)
  "openxlsx"     # Write .xlsx workbook (run_subsample_user_dict.R)
)

if (MIRROR_REPO == "YOUR_MIRROR_ADDRESS_HERE" || MIRROR_TOKEN == "YOUR_TOKEN_HERE") {
  stop("Mirror address or token not set.\n",
       "  Edit install_packages_mirror.r and set MIRROR_REPO and MIRROR_TOKEN.")
}

installed    <- rownames(installed.packages())
missing_pkgs <- required_packages[!required_packages %in% installed]
if (length(missing_pkgs) > 0) {
  install.packages(missing_pkgs, repos = MIRROR_REPO,
                   headers = c(Authorization = paste("Bearer", MIRROR_TOKEN)),
                   dependencies = TRUE)
}
for (pkg in required_packages) {
  ok <- suppressWarnings(tryCatch({ library(pkg, character.only = TRUE, quietly = TRUE); TRUE },
                                  error = function(e) FALSE))
  cat(sprintf("  [%s] %s\n", if (ok) "OK" else "FAIL", pkg))
}
