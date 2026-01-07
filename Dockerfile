# syntax=docker/dockerfile:1
# Enable BuildKit for better build performance and heredoc support
# BuildKit provides improved caching, parallel builds, and advanced Dockerfile features
# To build: docker build -t brms-workshop .
# To run:   docker compose up -d

# Base image: rocker/verse with R 4.5.2
# rocker/verse includes:
# - Base R installation (4.5.2)
# - RStudio Server (2025.09.2+418)
# - tidyverse packages pre-installed
# - TeX Live for PDF/LaTeX document generation
# - Publishing tools (rmarkdown, bookdown, blogdown)
# See: https://rocker-project.org/images/versioned/rstudio.html
FROM rocker/verse:4.5.2

# Stan compilation optimization environment variables
# These significantly speed up CmdStan installation and model compilation
# CMDSTAN_INSTALL_TIMEOUT: Allow 1 hour for CmdStan installation (default may timeout)
# MAKEFLAGS: Use 4 parallel make jobs for C++ compilation
# CMDSTANR_INSTALL_CORES: CmdStan install uses 4 cores (adjust for your CPU)
# DEBIAN_FRONTEND: Suppress interactive apt prompts during build
ENV CMDSTAN_INSTALL_TIMEOUT=3600 \
    MAKEFLAGS="-j4" \
    CMDSTANR_INSTALL_CORES=4 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies required for Stan and R packages
# Combined in a single RUN layer to minimize image size
# - build-essential: GCC, make, and other compilation tools
# - g++: C++ compiler required by Stan
# - libcurl4-openssl-dev: Development headers for curl (httr, httr2)
# - libssl-dev: OpenSSL headers for secure connections
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    g++ \
    libcurl4-openssl-dev \
    libssl-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Update TeX Live and install additional LaTeX packages
# Required for advanced document typesetting in RMarkdown/Quarto
# - tlmgr update --self: Update TeX Live package manager itself
# - unicode-math: Unicode math fonts support
# - xetex: XeTeX engine for modern font support
# Install common LaTeX packages needed for R Markdown PDF output
# This prevents knitr/rmarkdown from trying to download them on the fly
# unicode-math/xetex: For modern font support
# amsfonts, booktabs, caption: Common packages for academic papers
# tcolorbox, pdfcol, fontawesome5, float: Required by Quarto for callouts and formatting
RUN tlmgr update --self \
    && tlmgr install unicode-math xetex amsfonts booktabs caption \
                     tcolorbox pdfcol fontawesome5 float \
    && rm -rf /tmp/*

# Set working directory for workshop materials
# This is where RStudio will open by default
WORKDIR /home/rstudio/workshop

# Layer optimization: Copy install.R first, before materials
# Docker caches layers - install.R changes less frequently than materials
# This means we only re-run expensive R package installation when dependencies change
COPY --chown=rstudio:rstudio install.R .

# Install R packages (brms, cmdstanr, tidyverse extensions, etc.)
# This is the longest build step (~10-30 minutes depending on system)
# Layer is cached unless install.R changes
RUN R --no-save --no-restore -f install.R \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copy workshop materials last - these change most frequently during development
# By copying last, we avoid invalidating expensive package installation cache
COPY --chown=rstudio:rstudio materials/ ./materials/

# Create .Rprofile to automatically configure CmdStan path
# Uses heredoc syntax (<<'EOF') for cleaner multi-line content
# This runs every time R starts, ensuring cmdstanr knows where CmdStan is installed
RUN mkdir -p /home/rstudio && cat > /home/rstudio/.Rprofile <<'EOF'
# .Rprofile: Auto-detect and configure CmdStan path on R startup
# This ensures brms and cmdstanr can find the Stan compiler without manual configuration
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  tryCatch({
    # Try to get existing CmdStan path (if already configured)
    cmdstan_path <- tryCatch(cmdstanr::cmdstan_path(), error = function(e) NULL)
    
    # If no path is set, search for CmdStan installation in ~/.cmdstan
    if (is.null(cmdstan_path)) {
      cmdstan_base <- file.path(Sys.getenv("HOME"), ".cmdstan")
      if (dir.exists(cmdstan_base)) {
        possible_paths <- list.dirs(cmdstan_base, recursive = FALSE, full.names = TRUE)
        cmdstan_dirs <- grep("cmdstan-", possible_paths, value = TRUE)
        if (length(cmdstan_dirs) > 0) {
          # Use the most recent version (sorted descending)
          cmdstan_path <- sort(cmdstan_dirs, decreasing = TRUE)[1]
          cmdstanr::set_cmdstan_path(cmdstan_path)
          cat("✓ CmdStan path set to:", cmdstan_path, "\n")
        }
      }
    } else {
      cat("✓ Using existing CmdStan at:", cmdstan_path, "\n")
    }
  }, error = function(e) {
    # If auto-detection fails, provide helpful message
    message("Note: CmdStan path could not be auto-detected. Run cmdstanr::install_cmdstan() if needed.")
  })
}
EOF

# Set correct file permissions for rstudio user
# Combined in single RUN to avoid extra layers
# - chown: Ensure rstudio user owns all files
# - chmod 755: Directories are readable and executable
# - chmod 644: Files are readable but not executable
RUN chown -R rstudio:rstudio /home/rstudio \
    && chmod 755 /home/rstudio \
    && chmod 644 /home/rstudio/.Rprofile \
    && chmod -R 755 /home/rstudio/workshop \
    && find /home/rstudio/workshop -type f -exec chmod 644 {} \;

# Health check to verify RStudio Server is running and responding
# Docker/compose will mark container as unhealthy if this fails
# --interval: Check every 30 seconds
# --timeout: Fail if check takes >3 seconds
# --start-period: 40s grace period during container startup
# --retries: Mark unhealthy after 3 consecutive failures
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8787/ || exit 1

# Expose RStudio Server web interface port
# Access at http://localhost:8787 when running
EXPOSE 8787

# OCI image metadata labels for documentation and registry display
# See: https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.title="BRMS Workshop" \
      org.opencontainers.image.description="R workshop environment with brms and CmdStan for Bayesian modeling" \
      org.opencontainers.image.version="4.5.2" \
      org.opencontainers.image.authors="jobschepens" \
      org.opencontainers.image.url="https://github.com/jobschepens/brms-workshop" \
      org.opencontainers.image.source="https://github.com/jobschepens/brms-workshop" \
      org.opencontainers.image.vendor="jobschepens" \
      org.opencontainers.image.licenses="MIT" \
      maintainer="jobschepens"

# Note: Container entrypoint and CMD are inherited from rocker/verse base image
# Default command starts RStudio Server on port 8787
