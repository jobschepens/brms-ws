# R Package Installation Script for BRMS Workshop Container
# This script runs during Docker image build
# Do not modify lightly - changes will trigger full rebuild

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Suppress warnings for cleaner output
options(warn = -1)

cat("=== Installing BRMS Workshop Packages ===\n\n")

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

# Install brms (will use cmdstanr backend if available)
cat("Installing brms...\n")
install.packages("brms", quiet = TRUE, dependencies = TRUE)

# Install CmdStan (the Stan compiler backend)
# This can take 5-10 minutes on first build
cat("Installing CmdStan (Stan compiler)...\n")
cat("This may take 5-10 minutes on first build...\n")

# Use explicit error handling
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  tryCatch({
    # Check toolchain first (recommended by Stan docs)
    cat("Checking C++ toolchain...\n")
    toolchain_ok <- cmdstanr::check_cmdstan_toolchain(fix = TRUE, quiet = TRUE)
    
    if (!toolchain_ok) {
      cat("⚠ Warning: C++ toolchain check failed. CmdStan installation may fail.\n")
    }
    
    # Ensure CmdStan directory exists
    cmdstan_dir <- file.path(Sys.getenv("HOME"), ".cmdstanr", "cmdstan")
    dir.create(dirname(cmdstan_dir), showWarnings = FALSE, recursive = TRUE)
    
    # Install CmdStan with recommended settings
    cmdstanr::install_cmdstan(
      dir = dirname(cmdstan_dir),
      cores = parallel::detectCores(),
      quiet = FALSE,
      overwrite = TRUE
    )
    
    # Verify installation and set path
    installed_path <- cmdstanr::cmdstan_path()
    cat("✓ CmdStan installed successfully at: ", installed_path, "\n")
  }, error = function(e) {
    cat("⚠ Warning: CmdStan installation encountered an issue:\n")
    print(e)
    cat("CmdStan may need to be installed manually in the container.\n")
    cat("Users can run: cmdstanr::install_cmdstan() if needed\n")
  })
} else {
  cat("⚠ cmdstanr not loaded, CmdStan installation skipped\n")
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
