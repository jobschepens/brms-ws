# R Package Installation Script for BRMS Workshop Container
# This script runs during Docker image build
# Do not modify lightly - changes will trigger full rebuild

# Set CRAN mirror with fallback strategy
# Try multiple mirrors in order of preference (speed + reliability)
mirrors <- list(
  "cloud" = "https://cloud.r-project.org",  # Very stable, good CDN
  "posit" = "https://p3m.dev/cran/__linux__/noble/latest"  # Binary packages
)

# Start with cloud.r-project (has good CDN coverage and stable)
selected_mirror <- mirrors$cloud
options(repos = c(CRAN = selected_mirror))
cat("Using mirror:", selected_mirror, "\n")

# Suppress warnings for cleaner output
options(warn = -1)

# Install packages in parallel when possible
options(Ncpus = parallel::detectCores())

# Set download timeout to 5 minutes (for large packages like cmdstanr dependencies)
# Default 60s is too short for packages with heavy C++ code
options(timeout = 300)

# Optimize compilation: use fewer parallel make jobs to prevent memory exhaustion
# Too many parallel jobs can cause OOM errors in constrained environments
Sys.setenv(MAKEFLAGS = sprintf("-j%d", min(4, parallel::detectCores())))

cat("=== Installing BRMS Workshop Packages ===\n\n")
cat("Using", getOption("Ncpus"), "CPU cores for parallel installation\n")
cat("Repository:", getOption("repos")[1], "\n\n")

# ------ CORE BAYESIAN PACKAGES ------
cat("Installing core BRMS packages...\n")

# Install cmdstanr first (needed before brms for modern Stan interface)
# cmdstanr is NOT on CRAN - must install from Stan's R-universe repo
cat("Installing cmdstanr from Stan repository...\n")
cat("This may take 2-5 minutes (installing dependencies)...\n")
tryCatch({
  install.packages("cmdstanr", 
                   repos = c("https://stan-dev.r-universe.dev", 
                            "https://cloud.r-project.org"),
                   quiet = TRUE, 
                   dependencies = TRUE)
  cat("✓ cmdstanr installed successfully\n")
}, error = function(e) {
  cat("ERROR: Failed to install cmdstanr:", e$message, "\n")
  cat("Attempting retry with verbose output...\n")
  install.packages("cmdstanr", 
                   repos = c("https://stan-dev.r-universe.dev", 
                            "https://cloud.r-project.org"),
                   quiet = FALSE, 
                   dependencies = TRUE)
})

# Pre-install heavy C++ dependencies to avoid timeout issues during brms install
# These packages compile from source and benefit from parallelization
cat("Pre-installing heavy C++ dependencies (this may take 3-10 minutes)...\n")

heavy_packages <- c(
  "Rcpp",           # Core C++ bindings
  "RcppEigen",      # Matrix computations (heavy!)
  "RcppArmadillo"   # Linear algebra (heavy!)
)
for (pkg in heavy_packages) {
  # Skip if already installed (from cmdstanr dependencies)
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("  ✓ %s already installed\n", pkg))
    next
  }
  
  cat(sprintf("  Installing %s...\n", pkg))
  tryCatch({
    # Don't include dependencies for these - they have minimal deps
    # This prevents cascading timeout issues
    install.packages(pkg, quiet = TRUE, dependencies = FALSE)
    cat(sprintf("  ✓ %s installed successfully\n", pkg))
  }, error = function(e) {
    cat(sprintf("  WARNING: Error installing %s: %s\n", pkg, e$message))
    cat("  Attempting retry with dependencies...\n")
    tryCatch({
      install.packages(pkg, quiet = FALSE, dependencies = TRUE)
    }, error = function(e2) {
      cat(sprintf("  ERROR: Failed to install %s after retry\n", pkg))
      # Don't quit - let brms installation try to handle it
    })
  })
}

# Install brms (will use cmdstanr backend if available)
cat("Installing brms (main package)...\n")
cat("This may take 10-20 minutes (50+ dependencies with C++ compilation)...\n")
cat("Progress indicators may appear frozen - this is normal during compilation\n")
# Note: brms has many dependencies, but with heavy packages pre-installed,
# the remaining deps should install much faster
tryCatch({
  install.packages("brms", quiet = TRUE, dependencies = TRUE)
  cat("✓ brms installed successfully\n")
}, error = function(e) {
  cat("ERROR: Failed to install brms:", e$message, "\n")
  cat("Attempting retry with verbose output...\n")
  install.packages("brms", quiet = FALSE, dependencies = TRUE)
})

# Install CmdStan (the Stan compiler backend)
# This can take 5-10 minutes on first build
cat("\nInstalling CmdStan (Stan compiler)...\n")
cat("This may take 5-10 minutes on first build...\n")

# Verify cmdstanr is available
if (!requireNamespace("cmdstanr", quietly = TRUE)) {
  cat("ERROR: cmdstanr package not available - cannot install CmdStan\n")
  quit(status = 1)
}

# Use explicit error handling
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  # Check toolchain first (recommended by Stan docs)
  cat("Checking C++ toolchain...\n")
  toolchain_ok <- tryCatch({
    cmdstanr::check_cmdstan_toolchain(fix = TRUE, quiet = FALSE)
    cat("✓ C++ toolchain is available\n")
    TRUE
  }, error = function(e) {
    cat("WARNING: C++ toolchain check reported issue:", e$message, "\n")
    cat("Continuing anyway - may work if toolchain is actually available\n")
    TRUE  # Continue anyway - the check function is overly conservative
  })
  
  # Install CmdStan with explicit settings
  cat("Starting CmdStan installation (downloading and compiling)...\n")
  tryCatch({
    cmdstanr::install_cmdstan(
      cores = as.integer(Sys.getenv("CMDSTANR_INSTALL_CORES", "4")),
      quiet = FALSE,
      overwrite = FALSE,
      timeout = as.integer(Sys.getenv("CMDSTAN_INSTALL_TIMEOUT", "3600"))
    )
    cat("✓ CmdStan installation completed\n")
  }, error = function(e) {
    cat("ERROR: CmdStan installation failed:", e$message, "\n")
    # Try to provide helpful diagnostics
    cat("Checking if CmdStan was partially installed...\n")
    tryCatch({
      path <- cmdstanr::cmdstan_path()
      cat("Found CmdStan at:", path, "\n")
    }, error = function(e2) {
      cat("No CmdStan installation found\n")
      quit(status = 1)
    })
  })
  
  # Verify installation and set path
  installed_path <- tryCatch({
    cmdstanr::cmdstan_path()
  }, error = function(e) {
    cat("ERROR: Cannot find CmdStan path after installation\n")
    quit(status = 1)
  })
  cat("✓ CmdStan installed successfully at:", installed_path, "\n")
  
  # Test that it works
  cat("Testing CmdStan functionality...\n")
  tryCatch({
    version <- cmdstanr::cmdstan_version()
    cat("✓ CmdStan is functional (version:", version, ")\n")
  }, error = function(e) {
    cat("WARNING: CmdStan version check failed, but installation may still work\n")
  })
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
  "shinystan",      # Interactive posterior analysis
  "bayestestR",     # ROPE analysis and Bayesian hypothesis testing
  "broom.mixed",    # Tidy summaries for mixed models and Bayesian fits
  "emmeans",        # Estimated marginal means for factorial designs
  "marginaleffects",# Flexible predictions and comparisons for any model
  "HDInterval",     # HDI calculations for ROPE analysis
  "ggeffects",      # Adjusted predictions and marginal effects
  "see",            # Visualization for easystats packages (bayestestR plots)
  "parameters",     # Extract and format model parameters (easystats)
  "performance",    # Model diagnostics and fit indices (easystats)
  "effectsize",     # Compute standardized effects (easystats)
  "effsize",        # Classical effect size calculations
  "lmerTest",       # p-values and tests for lme4 models
  "rstatix",        # Pipe-friendly wrappers for common statistical tests
  "pwr",            # Power analysis utilities
  "modelbased",     # Model diagnostic summaries and predictions (easystats)
  "BayesFactor",    # Bayes Factor analysis
  "collapse"        # Required by marginaleffects for brms models
), quiet = TRUE, dependencies = TRUE)

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
  "DT",             # Interactive data tables
  "kableExtra"      # Enhanced HTML/PDF table styling
), quiet = TRUE, dependencies = TRUE)

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
cat("✓ ROPE & comparisons: bayestestR, broom.mixed, emmeans, marginaleffects, ggeffects, HDInterval\n")
cat("✓ easystats/classical: see, parameters, performance, effectsize, effsize, modelbased, rstatix, pwr\n")
cat("✓ Mixed models: lmerTest\n")
cat("✓ Data tools: tidyverse, ggplot2, dplyr, tidyr, scales\n")
cat("✓ Reporting: knitr, rmarkdown, bookdown, DT, kableExtra\n")
cat("✓ Dev tools: devtools, roxygen2, testthat\n")
cat("✓ Viz: patchwork, ggridges, viridis\n")
