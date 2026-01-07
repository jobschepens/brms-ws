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

### 4. Comparing Priors 
Sensitivity analysis: fit models with different priors and compare posteriors to check robustness. Understand how prior choice affects inference.

**See**: `04_comparing_priors.md`

### 5. LOO Cross-Validation 
Efficient leave-one-out cross-validation for model comparison. Compare nested and non-nested models using expected log pointwise predictive density (elpd).

**See**: `05_loo.md`

**Note**: We will discuss CV variants later:
- **LOO**: Standard leave-one-out cross-validation
- **k-fold CV for multilevel models**: Sample from groups for unseen data of existing subjects
- **LOGO-CV**: Leave-one-group-out cross-validation for unseen subjects

### 6. Practical Significance and Effect Estimation
Test practical significance using ROPE (Region of Practical Equivalence) and estimate effects in factorial designs. Understand decision-theoretic foundations.

**See**: `06_rope.qmd`

**Topics covered:**
- **ROPE (Region of Practical Equivalence)**: Define what's "too small to matter" based on domain knowledge
- **Decision Analysis Framework**: How ROPE implements Bayesian decision theory with utility functions
- **emmeans**: Estimated marginal means for factorial designs with automatic pairwise comparisons
- **marginaleffects**: Flexible predictions and comparisons for any model type
- **Integration**: Combine ROPE with effect estimation for complete inference

**Key insight**: ROPE is not just a hypothesis test—it's a decision framework that encodes your utility function through boundary choices.

### 7. Bayes Factors and Hypothesis Testing
Quantify evidence for one hypothesis over another using Bayes Factors. Compare competing theories and models.

**See**: `07_bayes_factors.qmd`

**Topics covered:**
- **`hypothesis()` function**: Compute Bayes Factors using Savage-Dickey density ratio method
- **`bayes_factor()` function**: Compare full models using bridge sampling
- **Interpretation guidelines**: Evidence scales (Jeffreys, Lee & Wagenmakers)
- **Comparison with ROPE**: Different questions (evidence vs. practical significance)
- **Prior sensitivity**: How Bayes Factors depend on prior specification

**Key distinction**: Bayes Factors answer "Which hypothesis is better supported?" while ROPE answers "Is the effect meaningful?"

### 8. Convergence Diagnostics
Ensure MCMC chains have converged before interpreting results. Learn to diagnose and fix convergence problems.

**See**: `08_convergence.qmd`

**Topics covered:**
- **Trace plots**: Visual inspection of chain behavior and mixing
- **R-hat statistic**: Quantitative measure of convergence (must be < 1.01)
- **Effective Sample Size (ESS)**: How many independent samples you really have (need > 400)
- **Autocorrelation**: How correlated consecutive samples are
- **Substantive sense checks**: Do parameter values make domain sense?
- **Iteration doubling test**: Does inference change with more samples?
- **Troubleshooting**: How to fix divergent transitions, low ESS, and poor mixing

**Critical**: Always check convergence before interpreting any results!

---

## For Later 

- **Other DV Types**: Count data, ordinal responses, bounded continuous data
- **Reporting Results**: Publishing Bayesian mixed effects models and writing methods sections

---

## Resources

**Core Textbooks:**
- Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., & Rubin, D. B. (2013). *Bayesian Data Analysis* (3rd ed.). CRC Press. [Free PDF](http://www.stat.columbia.edu/~gelman/book/)
- Kruschke, J. K. (2015). *Doing Bayesian Data Analysis* (2nd ed.). Academic Press.
- Nicenboim, B., Schad, D., & Vasishth, S. (2023). *An Introduction to Bayesian Data Analysis for Cognitive Science*. [Free online](https://vasishth.github.io/bayescogsci/book/)
- McElreath, R. (2020). *Statistical Rethinking* (2nd ed.). CRC Press.

**Applied Linguistics:**
- Vasishth, S., et al. (2018). "Bayesian data analysis in the phonetic sciences." *Journal of Phonetics*, 71, 147-161.
- Nicenboim, B., & Vasishth, S. (2016). "Statistical methods for linguistic research: Foundational Ideas—Part II." *Language and Linguistics Compass*, 10(11), 591-613.

**brms and Stan:**
- brms documentation: https://paul-buerkner.github.io/brms/
- Stan User's Guide: https://mc-stan.org/docs/stan-users-guide/
- Prior choice recommendations: https://github.com/stan-dev/stan/wiki/Prior-Choice-Recommendations

**Key Papers for This Workshop:**
- **Module 06**: Kruschke, J. K. (2018). "Rejecting or accepting parameter values in Bayesian estimation." *AMPPS*, 1(2), 270-280. [ROPE framework]
- **Module 06**: Gelman et al. (2013), Chapter 9 on Decision Analysis [Theoretical foundation for ROPE]
- **Module 07**: Wagenmakers, E.-J., et al. (2010). "Bayesian hypothesis testing: A tutorial on the Savage-Dickey method." *Cognitive Psychology*, 60(3), 158-189.
- **Module 08**: Vehtari, A., et al. (2021). "Rank-normalization, folding, and localization: An improved R-hat." *Bayesian Analysis*, 16(2), 667-718.
