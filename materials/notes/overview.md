# Bayesian Mixed Effects Models with brms for Linguists (1.5 hours)

## Workshop Overview

This workshop covers the fundamentals of Bayesian mixed effects modeling using brms, with a focus on two common psycholinguistics experiments:
1. **Reaction Time (RT) data** - continuous response times (log-transformed)
2. **Grammaticality Judgments** - binary acceptability judgments (logistic regression)

## Core Topics - To Cover in Workshop 

### 1. Setting Priors in brms 
Learn how to specify domain-specific priors instead of using brms defaults. Understand the difference between flat, weakly informative, and regularizing priors.

**See**: `01_setting_priors.md`

### 2. Prior Predictive Checks 
Validate your priors BEFORE fitting the model. Check if your prior assumptions generate reasonable predictions from the data.

**See**: `02_prior_predictive_checks.md`

### 3. Posterior Predictive Checks 
After fitting, check if the model generates data similar to what you observed. Assess model adequacy.

**See**: `03_posterior_predictive_checks.md`

---

## For Later 

- **Comparing Priors**: Sensitivity analysis: fit models with different priors and compare posteriors to check robustness. **See**: `04_comparing_priors_qa.md`

- **Convergence Diagnostics**: Visualize and assess MCMC sampling quality
  - `mcmc_plot`: Visualization of posterior estimates
  - `mcmc_dens_overlay`: Overlay of posterior distributions

- **Inference with Hypothesis and ROPE**: Test directional effects and practical significance
  - Using `hypothesis()` to specify contrasts and test specific predictions
  - Region of Practical Equivalence (ROPE): Define zones of practical equivalence around zero or other reference values
  - Distinguish between statistical significance and practical significance

- **Model Comparison with Bayes Factors**: Compare evidence between models
  - Bayes Factors for nested models and how posterior odds depend on prior specification
  - Sensitivity to prior choice and importance of defensible priors
  
- **LOO Cross-Validation**: Efficient leave-one-out CV for model comparison
  - Comparing nested models using LOO
  - Comparing non-nested models with LOO
  - Using expected log pointwise predictive density (elpd) for model ranking

- **Other DV Types**: Count data, ordinal responses, bounded continuous data
- **Reporting Results**: Publishing Bayesian mixed effects models

---

## Resources

- Vasishth et al. (2018). "Bayesian data analysis in the phonetic sciences"
- Nicenboim, Schad & Vasishth (in progress). "An Introduction to Bayesian Data Analysis for Cognitive Science"
- brms documentation: https://paul-buerkner.github.io/brms/
- Prior choice recommendations: https://github.com/stan-dev/stan/wiki/Prior-Choice-Recommendations
