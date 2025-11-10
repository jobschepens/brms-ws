# BRMS Workshop Docker Image

A production-ready, containerized Bayesian Regression Models using Stan (BRMS) workshop environment. Everything you need is pre-installed.

## Quick Start

### Pull the image
```bash
docker pull jobschepens/brms-workshop:working
```

### Run with Docker Compose
```bash
git clone https://github.com/jobschepens/brms-ws.git
cd brms-ws
docker-compose up
```

Then open your browser to `http://localhost:8787`

**Login credentials:**
- Username: `rstudio`
- Password: `workshop`

### Run standalone
```bash
docker run -d -p 8787:8787 \
  -e PASSWORD=workshop \
  jobschepens/brms-workshop:working
```

Then access RStudio Server at `http://localhost:8787`

## What's Included

| Component | Version |
|-----------|---------|
| **R** | 4.4.1 |
| **BRMS** | 2.22.0+ |
| **CmdStan** | Latest (pre-compiled) |
| **RStudio Server** | Latest |
| **Analysis Tools** | bayesplot, tidybayes, loo, projpred |
| **Data Tools** | tidyverse, ggplot2, dplyr |
| **Reporting** | R Markdown, knitr, bookdown, LaTeX |

## Features

✅ **Bayesian modeling** with BRMS and Stan  
✅ **Data science tools** for analysis and visualization  
✅ **Publication-ready** with LaTeX and bookdown  
✅ **RStudio Server** for web-based development  
✅ **Pre-compiled** CmdStan for fast model fitting  
✅ **Full TeX Live** for document generation

## Volume Mounts

When using docker-compose, the following volumes are automatically mounted:

- `./materials:/home/rstudio/workshop/materials` - Workshop materials
- `./results:/home/rstudio/workshop/results` - Output results

## Environment Variables

- `PASSWORD` - RStudio login password (default: `workshop`)
- `USERID` - RStudio user ID (default: `1000`)

## Documentation

For more information and alternative deployment methods, see:
- **GitHub Repository**: https://github.com/jobschepens/brms-ws
- **Binder** (web-based, no installation): [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/jobschepens/brms-ws/main?urlpath=rstudio)
- **GitHub Codespaces** (cloud IDE): [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/jobschepens/brms-ws)

## License

See LICENSE file in the [GitHub repository](https://github.com/jobschepens/brms-ws)

## Support

For issues and questions:
- Open an issue on [GitHub](https://github.com/jobschepens/brms-ws/issues)
- Check the main [README](https://github.com/jobschepens/brms-ws/blob/main/README.md)
