FROM rocker/verse:4.4.1

# Set environment variables
ENV CMDSTAN_INSTALL_TIMEOUT=3600
ENV MAKEFLAGS=-j4
ENV CMDSTANR_INSTALL_CORES=4

# Install system dependencies and TeX Live packages
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Update TeX Live and install additional packages
RUN tlmgr update --self && tlmgr install unicode-math xetex

# Set working directory
WORKDIR /home/rstudio/workshop

# Copy installation script
COPY install.R .

# Run R package installation
RUN R --quiet --slave -f install.R

# Copy workshop materials
COPY materials/ ./materials/

# Create R profile to set CmdStan path on startup
RUN mkdir -p /home/rstudio
COPY <<EOF /home/rstudio/.Rprofile
# Auto-detect and set CmdStan path
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  tryCatch({
    # Check if CmdStan is already installed
    cmdstan_path <- cmdstanr::cmdstan_path()
    if (is.null(cmdstan_path) || !file.exists(cmdstan_path)) {
      # Try to find CmdStan installation
      possible_paths <- c(
        file.path(Sys.getenv("HOME"), ".cmdstanr", "cmdstan"),
        file.path(Sys.getenv("HOME"), ".local", "share", "cmdstan"),
        "/opt/cmdstan"
      )
      for (path in possible_paths) {
        if (file.exists(path)) {
          cmdstanr::set_cmdstan_path(path)
          break
        }
      }
    }
  }, error = function(e) {
    # Silently fail if CmdStan setup fails
  })
}
EOF

# Set permissions
RUN chown rstudio:rstudio /home/rstudio/.Rprofile && \
    chmod 644 /home/rstudio/.Rprofile

# Expose RStudio port
EXPOSE 8787
