FROM rocker/verse:4.4.1

# Set environment variables
ENV CMDSTAN_INSTALL_TIMEOUT=3600
ENV MAKEFLAGS=-j4
ENV CMDSTANR_INSTALL_CORES=4

# Install system dependencies and TeX Live packages
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    libcurl4-openssl-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Update TeX Live and install additional packages
RUN tlmgr update --self && tlmgr install unicode-math xetex

# Set working directory
WORKDIR /home/rstudio/workshop

# Copy installation script
COPY install.R .

# Run R package installation (installs packages system-wide and CmdStan as root)
RUN R --no-save --no-restore -f install.R

# Copy workshop materials with proper permissions
COPY --chown=rstudio:rstudio materials/ ./materials/

# Create R profile to set CmdStan path on startup for rstudio user
RUN mkdir -p /home/rstudio && \
    printf '%s\n' \
    '# Auto-detect and set CmdStan path' \
    'if (requireNamespace("cmdstanr", quietly = TRUE)) {' \
    '  tryCatch({' \
    '    # Try to get existing path first' \
    '    cmdstan_path <- tryCatch(cmdstanr::cmdstan_path(), error = function(e) NULL)' \
    '    ' \
    '    # If no path set, search for it in user home directory' \
    '    if (is.null(cmdstan_path)) {' \
    '      cmdstan_base <- file.path(Sys.getenv("HOME"), ".cmdstan")' \
    '      if (dir.exists(cmdstan_base)) {' \
    '        possible_paths <- list.dirs(cmdstan_base, recursive = FALSE, full.names = TRUE)' \
    '        cmdstan_dirs <- grep("cmdstan-", possible_paths, value = TRUE)' \
    '        if (length(cmdstan_dirs) > 0) {' \
    '          # Use the most recent version' \
    '          cmdstan_path <- sort(cmdstan_dirs, decreasing = TRUE)[1]' \
    '          cmdstanr::set_cmdstan_path(cmdstan_path)' \
    '          cat("✓ CmdStan path set to:", cmdstan_path, "\n")' \
    '        }' \
    '      }' \
    '    }' \
    '  }, error = function(e) {' \
    '    message("Note: CmdStan path could not be auto-detected. Run cmdstanr::install_cmdstan() if needed.")' \
    '  })' \
    '}' \
    > /home/rstudio/.Rprofile

# Set proper permissions for .Rprofile and workshop directory
RUN chown -R rstudio:rstudio /home/rstudio && \
    chmod 755 /home/rstudio && \
    chmod 644 /home/rstudio/.Rprofile && \
    chmod -R 755 /home/rstudio/workshop && \
    find /home/rstudio/workshop -type f -exec chmod 644 {} \;

# Expose RStudio port
EXPOSE 8787
