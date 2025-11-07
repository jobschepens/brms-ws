# BRMS Workshop Container

A production-ready, containerized Bayesian Regression Models using Stan (BRMS) workshop environment. Everything you need is pre-installed—just choose your deployment method!

---

## 🚀 Quick Start: Choose Your Path

### ⭐ **Binder** (Recommended for Workshops)
**Zero installation.** One click and you're coding!

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/jobschepens/brms-ws/main?urlpath=rstudio)

- No installation needed
- Free hosting
- Takes ~2-3 minutes first time
- Perfect for participants

### 🔧 **GitHub Codespaces** (Best for Development)
**Cloud IDE with full compute.**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/jobschepens/brms-ws)

- Full VS Code in browser
- Persistent development environment
- Free tier available (60 hours/month)
- Perfect for team development

### 💻 **Docker Desktop** (Local Control)
**Run locally on your machine.**

```bash
git clone https://github.com/jobschepens/brms-ws.git
cd brms-ws
docker-compose up
# Open http://localhost:8787 | Login: rstudio / workshop
```

### 🔗 **VS Code Remote** (For Teams)
**Connect to a running container from your IDE.**

```bash
docker run -d -p 2222:22 brms-workshop:working
# In VS Code: Install "Remote - SSH" extension
# Connect to user@server -p 2222
```

---

## 📦 What's Included

| Component | Version | Status |
|-----------|---------|--------|
| **R** | 4.4.1 | ✅ Pre-installed |
| **BRMS** | 2.22.0 | ✅ Pre-installed |
| **CmdStan** | Latest | ✅ Pre-compiled |
| **RStudio Server** | Latest | ✅ Ready to use |
| **Analysis Tools** | - | ✅ bayesplot, tidybayes, loo, projpred |
| **Data Tools** | - | ✅ tidyverse, ggplot2, dplyr |
| **Reporting** | - | ✅ R Markdown, knitr, bookdown, LaTeX |

---

## 🎓 Workshop Materials

Workshop notebooks in `materials/notebooks/`:

- **`example_01_basics.Rmd`** — Introduction to BRMS
  - Data preparation, linear regression, posterior visualization, predictions

---

## ⚡ First Time Setup

### In Binder
1. Click the Binder badge above
2. Wait 2-3 minutes for environment build
3. Navigate to `materials/notebooks/`
4. Open and run `example_01_basics.Rmd`

**Note**: First model takes ~30-60 seconds (Stan compilation), then everything is instant.

### Locally with Docker
```bash
docker-compose up
# Open http://localhost:8787 | Login: rstudio / workshop
docker-compose down  # When done
```

## 📋 System Requirements

| Option | Requirements |
|--------|--------------|
| **Binder** | Web browser + internet (free) |
| **Codespaces** | GitHub account (free: 60 hrs/month) |
| **Docker Desktop** | 15 GB disk space, 8+ GB RAM |
| **VS Code Remote** | Server with Docker |

---


Happy Bayesian modeling! 🎓

*Last Updated: November 7, 2025*

