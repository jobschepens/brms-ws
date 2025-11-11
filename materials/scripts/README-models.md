# Pre-fitting Models for Workshop Examples

## Overview

The posterior predictive check examples require fitted Bayesian models. Since model fitting can take 10-15 minutes, we pre-fit the models and save them to the `fits/` directory.

## Quick Start

### 1. Pre-fit the models (one time, ~15 minutes)

```bash
Rscript materials/scripts/00_fit_models.R
```

This will create:
- `materials/scripts/fits/fit_rt.rds` - Reaction time model
- `materials/scripts/fits/fit_gram.rds` - Grammaticality judgment model

### 2. Render the Quarto documents (instant)

```bash
cd materials/scripts
quarto render 03_posterior_predictive_checks_rt.qmd
quarto render 03_posterior_predictive_checks_gram.qmd
```

The documents will load the pre-fitted models instantly from the `fits/` directory.

## What models are fitted?

### RT Model
- **Formula**: `log_rt ~ condition + (1 + condition | subject) + (1 | item)`
- **Family**: `gaussian()`
- **Data**: 3000 observations (20 subjects × 50 trials × 3 items)
- **Priors**: Weakly informative (see script for details)

### Grammaticality Judgment Model
- **Formula**: `correct ~ condition + (1 + condition | subject) + (1 | item)`
- **Family**: `bernoulli()`
- **Data**: 2000 observations (25 subjects × 40 trials × 2 items)
- **Priors**: Weakly informative (see script for details)

## Refitting Models

To refit the models (e.g., after changing priors or data):

1. Delete the existing model files:
   ```bash
   rm materials/scripts/fits/fit_rt.rds
   rm materials/scripts/fits/fit_gram.rds
   ```

2. Run the fitting script again:
   ```bash
   Rscript materials/scripts/00_fit_models.R
   ```

## Troubleshooting

### Model fitting fails with memory errors

The Stan compilation can require significant memory. If you encounter errors:

1. **Reduce model complexity** in `00_fit_models.R`:
   - Decrease `chains` (e.g., from 2 to 1)
   - Decrease `iter` (e.g., from 1000 to 500)
   
2. **Use fewer cores**:
   - Change `cores = 2` to `cores = 1`

3. **Simplify the model**:
   - Remove random slopes: `(1 | subject)` instead of `(1 + condition | subject)`

### cmdstanr errors

The script uses `rstan` backend by default. If you have `cmdstanr` configured, the Quarto documents will detect and use it automatically.

## File Structure

```
materials/scripts/
├── 00_fit_models.R                         # Pre-fit models (run once)
├── 03_posterior_predictive_checks_rt.qmd   # RT example (loads fit_rt.rds)
├── 03_posterior_predictive_checks_gram.qmd # Gram example (loads fit_gram.rds)
└── fits/
    ├── fit_rt.rds                          # Saved RT model
    └── fit_gram.rds                        # Saved grammaticality model
```
