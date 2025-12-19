# R Package Installation Script for BRMS Workshop Container
# This script runs during Docker image build
# Do not modify lightly - changes will trigger full rebuild

# Set CRAN mirror - use posit package manager for pre-built binaries (faster!)
# For Ubuntu 24.04 (noble) - gets pre-compiled binary packages
options(repos = c(CRAN = "https://p3m.dev/cran/__linux__/noble/latest"))

# Alternative fallback mirror
if (!require("curl", quietly = TRUE)) {
  options(repos = c(CRAN = "https://cloud.r-project.org/"))
}

# Suppress warnings for cleaner output
options(warn = -1)

# Install packages in parallel when possible
options(Ncpus = parallel::detectCores())

# OPTIMIZATION: Use pre-built binary packages when available (MUCH faster than source!)
# This is critical for preventing timeouts on heavy packages like RcppEigen, rstan, etc.
options(pkgType = "binary")

cat("=== Installing BRMS Workshop Packages ===\n\n")
cat("Using", getOption("Ncpus"), "CPU cores for parallel installation\n")
cat("Repository:", getOption("repos")[1], "\n\n")

# ------ CORE BAYESIAN PACKAGES ------
cat("Installing core BRMS packages...\n")

# Install cmdstanr first (needed before brms for modern Stan interface)
# cmdstanr is NOT on CRAN - must install from Stan's R-universe repo
cat("Installing cmdstanr from Stan repository...\n")
install.packages("cmdstanr", 
                 repos = c("https://stan-dev.r-universe.dev", 
                          "https://cloud.r-project.org"),
                 quiet = TRUE, 
                 dependencies = TRUE)

# Pre-install heavy C++ dependencies to avoid timeout issues during brms install
cat("Pre-installing heavy C++ dependencies (to avoid timeout)...\n")
heavy_packages <- c(
  "Rcpp",           # Core C++ bindings
  "RcppEigen",      # Matrix computations (heavy!)
  "RcppArmadillo"   # Linear algebra (heavy!)
)
for (pkg in heavy_packages) {
  cat(sprintf("  Installing %s...\n", pkg))
  install.packages(pkg, quiet = TRUE, dependencies = FALSE)
}

# Install brms (will use cmdstanr backend if available)
cat("Installing brms (main package)...\n")
install.packages("brms", quiet = TRUE, dependencies = TRUE)

# Install CmdStan (the Stan compiler backend)
# This can take 5-10 minutes on first build
cat("Installing CmdStan (Stan compiler)...\n")
cat("This may take 5-10 minutes on first build...\n")

# Use explicit error handling
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  # Check toolchain first (recommended by Stan docs)
  cat("Checking C++ toolchain...\n")
  tryCatch({
    cmdstanr::check_cmdstan_toolchain(fix = TRUE, quiet = FALSE)
  }, error = function(e) {
    cat("ERROR: C++ toolchain check failed:", e$message, "\n")
    quit(status = 1)
  })
  
  # Install CmdStan with explicit settings
  cat("Starting CmdStan installation...\n")
  cmdstanr::install_cmdstan(
    cores = as.integer(Sys.getenv("CMDSTANR_INSTALL_CORES", "4")),
    quiet = FALSE,
    overwrite = FALSE,
    timeout = as.integer(Sys.getenv("CMDSTAN_INSTALL_TIMEOUT", "3600"))
  )
  
  # Verify installation and set path
  installed_path <- cmdstanr::cmdstan_path()
  cat("✓ CmdStan installed successfully at: ", installed_path, "\n")
  
  # Test that it works
  cat("Testing CmdStan installation...\n")
  cmdstanr::cmdstan_version()
  cat("✓ CmdStan is functional\n")
} else {
  cat("ERROR: cmdstanr package not available\n")
  quit(status = 1)
}

# ------ BAYESIAN ANALYSIS TOOLS ------
cat("Installing Bayesian analysis tools...\n")
install.packages(c(
  "bayesplot",      # Visualization of Bayesian posterior distributions
  "tidybayes",      # Tidy data tools for Bayesian analysis
  "loo",            # Leave-one-out cross-validation
  "projpred",       # Projection predictive inference
  "shinystan"       # Interactive posterior analysis
), quiet = TRUE)

# ------ DATA MANIPULATION & VISUALIZATION ------
cat("Installing data & visualization tools...\n")
install.packages(c(
  "tidyverse",      # Already in rocker/verse, but ensure latest
  "ggplot2",        # Plots
  "dplyr",          # Data wrangling
  "tidyr",          # Data tidying
  "scales"          # Scale transformations for plots
), quiet = TRUE)

# ------ DOCUMENTATION & REPORTING ------
cat("Installing documentation tools...\n")
install.packages(c(
  "knitr",          # Dynamic reports
  "rmarkdown",      # R Markdown documents
  "bookdown",       # Books/reports with cross-references
  "DT"              # Interactive data tables
), quiet = TRUE)

# ------ DEVELOPMENT TOOLS ------
cat("Installing development tools...\n")
install.packages(c(
  "devtools",       # Already in rocker/verse, but ensure latest
  "roxygen2",       # Documentation generation
  "testthat"        # Unit testing
), quiet = TRUE)

# ------ OPTIONAL: VISUALIZATION EXTENSIONS ------
cat("Installing visualization extensions...\n")
install.packages(c(
  "patchwork",      # Combine plots
  "ggridges",       # Ridge plots
  "viridis"         # Color scales
), quiet = TRUE)

# Success message
cat("\n=== Installation Complete ===\n")
cat("Packages installed:\n")
cat("✓ BRMS, cmdstanr, CmdStan\n")
cat("✓ Bayesian tools: bayesplot, tidybayes, loo, projpred, shinystan\n")
cat("✓ Data tools: tidyverse, ggplot2, dplyr, tidyr, scales\n")
cat("✓ Reporting: knitr, rmarkdown, bookdown, DT\n")
cat("✓ Dev tools: devtools, roxygen2, testthat\n")
cat("✓ Viz: patchwork, ggridges, viridis\n")
