FROM rocker/verse:4.4.1

# Set environment variables
ENV CMDSTAN_INSTALL_TIMEOUT=3600
ENV MAKEFLAGS=-j4

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

# Expose RStudio port
EXPOSE 8787
