# BRMS Workshop 

### 🐳 **GitHub Container Registry** (Alternative) 
**For users familiar with GitHub Packages.**

[![GitHub Actions Build](https://github.com/jobschepens/brms-ws/actions/workflows/docker-build.yml/badge.svg)](https://github.com/jobschepens/brms-ws/actions/workflows/docker-build.yml)

This is the primary source of the image, but for simplicity, we recommend using the Docker Hub image above. Accessing this image directly requires authenticating with GitHub to avoid download rate limits. See [instructions here](./README-ghcr.md).


### 🐳 **Docker Hub** (Pre-built Image)
**Ready-to-use container image.**

[![Docker Image](https://img.shields.io/badge/Docker%20Hub-jobschepens%2Fbrms--workshop-blue?logo=docker)](https://hub.docker.com/r/jobschepens/brms-workshop)

The easiest way to run the workshop locally. Just pull the image and run:
```bash
# Pull the image from Docker Hub
docker pull jobschepens/brms-workshop

# Run the container
docker run -d -p 8787:8787 -v "$(pwd)/materials:/home/rstudio/workshop/materials" jobschepens/brms-workshop
```
Open your browser to `http://localhost:8787` (login: `rstudio` / `workshop`).


### ⭐ **Binder** (Can be practical for Workshops)
**Zero installation.** One click and you're coding!

[![Binder (GHCR)](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/jobschepens/brms-ws/main?urlpath=rstudio)

- No installation needed
- Free hosting
- Takes ~2-3 minutes first time
- Perfect for participants
- Uses pre-built Docker image from GitHub Container Registry

### 🔧 **GitHub Codespaces** 
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

### 🔗 **VS Code Remote** (Recommended)
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

### Rendered HTML Scripts

View the rendered tutorials directly in your browser:

#### Module 1: Setting Priors
- [**01_setting_priors.html**](https://jobschepens.github.io/brms-ws/01_setting_priors.html) — Setting Priors
- [**01_setting_priors_gram.html**](https://jobschepens.github.io/brms-ws/01_setting_priors_gram.html) — Setting Priors (Grammaticality)

#### Module 2: Prior Predictive Checks
- [**02_prior_predictive_checks_rt.html**](https://jobschepens.github.io/brms-ws/02_prior_predictive_checks_rt.html) — Prior Predictive Checks (RT)
- [**02_prior_predictive_checks_gram.html**](https://jobschepens.github.io/brms-ws/02_prior_predictive_checks_gram.html) — Prior Predictive Checks (Grammaticality)

#### Module 3: Posterior Predictive Checks
- [**03_posterior_predictive_checks_rt.html**](https://jobschepens.github.io/brms-ws/03_posterior_predictive_checks_rt.html) — Posterior Predictive Checks (RT)
- [**03_posterior_predictive_checks_gram.html**](https://jobschepens.github.io/brms-ws/03_posterior_predictive_checks_gram.html) — Posterior Predictive Checks (Grammaticality)

#### Module 4: Comparing Priors
- [**04_comparing_priors_rt.html**](https://jobschepens.github.io/brms-ws/04_comparing_priors_rt.html) — Comparing Priors (RT)

#### Module 5: Model Comparison
- [**05_loo.html**](https://jobschepens.github.io/brms-ws/05_loo.html) — LOO-PSIS: Model Comparison with Cross-Validation (RT)

#### Module 6: Practical Significance and Effect Estimation
- [**06_rope.html**](https://jobschepens.github.io/brms-ws/06_rope.html) — ROPE, emmeans, and marginaleffects
  - Region of Practical Equivalence (ROPE) with decision-theoretic foundations
  - Estimated marginal means for factorial designs
  - Flexible predictions and comparisons
  - Integration of practical significance testing

#### Module 7: Bayes Factors and Hypothesis Testing
- [**07_bayes_factors.html**](https://jobschepens.github.io/brms-ws/07_bayes_factors.html) — Hypothesis Testing with Bayes Factors
  - Savage-Dickey density ratio method
  - Bridge sampling for model comparison
  - Evidence quantification and interpretation
  - Comparison with ROPE approach

#### Module 8: Convergence Diagnostics
- [**08_convergence.html**](https://jobschepens.github.io/brms-ws/08_convergence.html) — MCMC Convergence Diagnostics
  - Trace plots and visual inspection
  - R-hat and effective sample size (ESS)
  - Autocorrelation analysis
  - Troubleshooting convergence issues
  - Iteration doubling tests

### Workshop Notebooks

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
For detailed instructions on how to pull and run the image, please see the **[Docker Hub README](./README-docker.md)**.


## 📋 System Requirements

| Option | Requirements |
|--------|--------------|
| **Binder** | Web browser + internet (free) |
| **Codespaces** | GitHub account (free: 60 hrs/month) |
| **Docker Desktop** | 15 GB disk space, 8+ GB RAM |
| **VS Code Remote** | Server with Docker |

---


Happy Bayesian modeling! 🎓
