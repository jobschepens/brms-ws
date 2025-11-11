# Bayesian Mixed Effects Models with brms for Linguists (1.5 hours)

## Workshop Overview

This workshop covers the fundamentals of Bayesian mixed effects modeling using brms, with a focus on two common psycholinguistics experiments:
1. **Reaction Time (RT) data** - continuous response times (log-transformed)
2. **Grammaticality Judgments** - binary acceptability judgments (logistic regression)

## Core Topics - To Cover in Workshop (60-75 min)

### 1. Setting Priors in brms (20 min)
Learn how to specify domain-specific priors instead of using brms defaults. Understand the difference between flat, weakly informative, and regularizing priors.

**See**: `01_setting_priors.md`

### 2. Prior Predictive Checks (15 min)
Validate your priors BEFORE fitting the model. Check if your prior assumptions generate reasonable predictions from the data.

**See**: `02_prior_predictive_checks.md`

### 3. Posterior Predictive Checks (15 min)
After fitting, check if the model generates data similar to what you observed. Assess model adequacy.

**See**: `03_posterior_predictive_checks.md`

### 4. Comparing Priors & Q&A (15 min)
Sensitivity analysis: fit models with different priors and compare posteriors to check robustness. Answer common questions about prior choice.

**See**: `04_comparing_priors_qa.md`

### 5. Mixed Effects Structure & Wrap-up (10 min)
Understand partial pooling and how random effects help with exchangeability in hierarchical data. When to simplify model structure.

---

## Advanced Topics - For Later Discussion

- **Model Comparison**: LOO cross-validation and Bayes Factors
- **Sensitivity Analysis**: Robustness to prior specification
- **Convergence Issues**: Troubleshooting MCMC sampling problems
- **Other DV Types**: Count data, ordinal responses, bounded continuous data
- **Reporting Results**: Publishing Bayesian mixed effects models

---

## Key Concepts to Know

- **Prior interval** vs **Prior mass**: The distinction between parameters space and data space
- **Data-dependent priors**: How brms adapts Intercept priors (important!)
- **Improper vs proper priors**: Why flat priors still work mathematically
- **Domain knowledge**: The importance of using psycholinguistics literature to inform priors

---

## Resources

- Vasishth et al. (2018). "Bayesian data analysis in the phonetic sciences"
- Nicenboim, Schad & Vasishth (in progress). "An Introduction to Bayesian Data Analysis for Cognitive Science"
- brms documentation: https://paul-buerkner.github.io/brms/
- Prior choice recommendations: https://github.com/stan-dev/stan/wiki/Prior-Choice-Recommendations
