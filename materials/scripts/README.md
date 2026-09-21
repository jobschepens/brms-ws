# Bayesian Mixed Effects Models with brms for Linguists

## Workshop Overview

This workshop covers the fundamentals of Bayesian mixed effects modeling using `brms`, with a focus on two common psycholinguistic experimental paradigms:
1. **Reaction Time (RT) data** — continuous response times (log-transformed, Gaussian family)
2. **Grammaticality Judgments** — binary acceptability judgments (logistic regression, Bernoulli family)

---

## Core Modules

### 1. Setting Priors in brms
Learn how to specify domain-specific priors instead of relying on brms defaults. Understand the difference between flat, weakly informative, and regularizing priors.

- **Scripts**:
  - [`01_setting_priors.qmd`](./01_setting_priors.qmd) ([HTML](https://jobschepens.github.io/brms-ws/01_setting_priors.html)) — Continuous RT data
  - [`01_setting_priors_gram.qmd`](./01_setting_priors_gram.qmd) ([HTML](https://jobschepens.github.io/brms-ws/01_setting_priors_gram.html)) — Binary grammaticality judgments

### 2. Prior Predictive Checks
Validate your priors **before** fitting the model. Check whether your prior assumptions generate sensible predictions and prevent computational issues.

- **Scripts**:
  - [`02_prior_predictive_checks_rt.qmd`](./02_prior_predictive_checks_rt.qmd) ([HTML](https://jobschepens.github.io/brms-ws/02_prior_predictive_checks_rt.html)) — RT models
  - [`02_prior_predictive_checks_gram.qmd`](./02_prior_predictive_checks_gram.qmd) ([HTML](https://jobschepens.github.io/brms-ws/02_prior_predictive_checks_gram.html)) — Grammaticality models

### 3. Posterior Predictive Checks
After fitting, validate that the model generates data resembling observed patterns. Assess model adequacy, mean/variance recovery, and grouping structures.

- **Scripts**:
  - [`03_posterior_predictive_checks_rt.qmd`](./03_posterior_predictive_checks_rt.qmd) ([HTML](https://jobschepens.github.io/brms-ws/03_posterior_predictive_checks_rt.html)) — RT models
  - [`03_posterior_predictive_checks_gram.qmd`](./03_posterior_predictive_checks_gram.qmd) ([HTML](https://jobschepens.github.io/brms-ws/03_posterior_predictive_checks_gram.html)) — Grammaticality models

### 4. Comparing Priors (Sensitivity Analysis)
Fit models under different reasonable priors (domain-informed, wide, regularizing) and compare posteriors to check whether scientific conclusions are robust or fragile.

- **Script**: [`04_comparing_priors_rt.qmd`](./04_comparing_priors_rt.qmd) ([HTML](https://jobschepens.github.io/brms-ws/04_comparing_priors_rt.html))

### 5. Model Comparison with LOO Cross-Validation
Perform efficient Pareto-smoothed importance sampling leave-one-out cross-validation (`loo`) to compare nested and non-nested models via expected log pointwise predictive density (`elpd`).

- **Script**: [`05_loo.qmd`](./05_loo.qmd) ([HTML](https://jobschepens.github.io/brms-ws/05_loo.html))
- **CV Variants Discussed**:
  - **Standard LOO**: Pointwise leave-one-out cross-validation
  - **k-fold CV for multilevel models**: Grouped cross-validation for unseen data from existing clusters
  - **LOGO-CV**: Leave-one-group-out cross-validation for predicting unseen subjects/items

### 6. Practical Significance and Effect Estimation
Test practical significance using ROPE (Region of Practical Equivalence) and estimate marginal effects in factorial designs.

- **Scripts**:
  - [`06_rope.qmd`](./06_rope.qmd) ([HTML](https://jobschepens.github.io/brms-ws/06_rope.html)) — ROPE, `emmeans`, and `marginaleffects`
  - [`06_sequential_testing.qmd`](./06_sequential_testing.qmd) ([HTML](https://jobschepens.github.io/brms-ws/06_sequential_testing.html)) — Sequential Testing: ROPE vs Bayes Factor vs LOO
  - [`06_sequential_testing_cont.qmd`](./06_sequential_testing_cont.qmd) ([HTML](https://jobschepens.github.io/brms-ws/06_sequential_testing_cont.html)) — Sequential Testing for Continuous Designs
  - [`06_rope_literature.md`](./06_rope_literature.md) — Annotated bibliography on decision analysis & ROPE
- **Key Topics**:
  - **ROPE Boundaries**: Principled methods for defining what is "too small to matter"
  - **Decision Analysis Framework**: Encoding utility functions into inference (Gelman et al., 2013)
  - **`emmeans` & `marginaleffects`**: Contrasts, counterfactual predictions, and pairwise comparisons
  - **Sequential Testing**: Why Bayesian HDI/ROPE stopping does not inflate Type I error like NHST

### 7. Bayes Factors and Hypothesis Testing
Quantify evidence for competing hypotheses using Savage-Dickey density ratios and bridge sampling.

- **Script**: [`07_bayes_factors.qmd`](./07_bayes_factors.qmd) ([HTML](https://jobschepens.github.io/brms-ws/07_bayes_factors.html))
- **Key Topics**:
  - Point null testing with `brms::hypothesis()` (Savage-Dickey method)
  - Model-level comparison with `brms::bayes_factor()` (bridge sampling)
  - Evidence scales (Jeffreys; Lee & Wagenmakers)
  - Distinguishing evidence ("Which hypothesis has more support?") from magnitude ("Is the effect meaningful?")

### 8. MCMC Convergence Diagnostics
Ensure Markov chains have converged and mixed thoroughly before drawing inferences.

- **Script**: [`08_convergence.qmd`](./08_convergence.qmd) ([HTML](https://jobschepens.github.io/brms-ws/08_convergence.html))
- **Key Topics**:
  - Trace plots, rank plots, and autocorrelation analysis
  - $\hat{R}$ diagnostic ($\le 1.01$) and Effective Sample Size ($ESS_{bulk}$, $ESS_{tail} > 400$)
  - Diagnosing and fixing divergent transitions and energy Bayesian Fraction of Missing Information (E-BFMI)
  - Iteration doubling tests

---

## Further Topics

- **Additional Response Distributions**: Count data (Poisson, Negative Binomial), ordinal responses (Cumulative Probit/Logit), bounded continuous data (Beta, Zero-Inflated).
- **Reporting Standards**: Guidelines for reporting Bayesian multilevel models in journal manuscripts.

---

## Recommended Literature

### Core Textbooks
- **Gelman, A., et al. (2013).** *Bayesian Data Analysis* (3rd ed.). CRC Press. [Free PDF](http://www.stat.columbia.edu/~gelman/book/)
- **Kruschke, J. K. (2015).** *Doing Bayesian Data Analysis: A Tutorial with R, JAGS, and Stan* (2nd ed.). Academic Press.
- **Nicenboim, B., Schad, D., & Vasishth, S. (2023).** *An Introduction to Bayesian Data Analysis for Cognitive Science*. [Free online](https://vasishth.github.io/bayescogsci/book/)
- **McElreath, R. (2020).** *Statistical Rethinking: A Bayesian Course with Examples in R and Stan* (2nd ed.). CRC Press.
- **Kurz, A. S. (2023).** *Statistical Rethinking with brms, ggplot2, and the tidyverse*. [Free online](https://bookdown.org/content/3890/)

### Applied Linguistics & Phonetics
- **Vasishth, S., Nicenboim, B., Beckman, M. E., Li, F., & Kong, E. J. (2018).** Bayesian data analysis in the phonetic sciences: A tutorial introduction. *Journal of Phonetics*, 71, 147–161.
- **Nicenboim, B., & Vasishth, S. (2016).** Statistical methods for linguistic research: Foundational Ideas—Part II. *Language and Linguistics Compass*, 10(11), 591–613.

### Key Conceptual Papers
- **Kruschke, J. K. (2018).** Rejecting or accepting parameter values in Bayesian estimation. *Advances in Methods and Practices in Psychological Science*, 1(2), 270–280.
- **Wagenmakers, E.-J., et al. (2010).** Bayesian hypothesis testing for psychologists: A tutorial on the Savage-Dickey method. *Cognitive Psychology*, 60(3), 158–189.
- **Vehtari, A., Gelman, A., Simpson, D., Carpenter, B., & Bürkner, P.-C. (2021).** Rank-normalization, folding, and localization: An improved $\hat{R}$ for assessing convergence of MCMC. *Bayesian Analysis*, 16(2), 667–718.

