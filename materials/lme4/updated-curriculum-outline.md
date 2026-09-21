# Technical Specification, Methodological Review, and Curriculum Outline for Session 29: lme4 Model Criticism

**Course / Series**: Research Data and Methods Workshop Series  
**Session Title**: Session 29: lme4 Model Criticism & Advanced Mixed-Effects Diagnostics  
**Duration**: 90 Minutes (14:00 – 15:30)  
**Instructor**: Job Schepens  

---

## Workshop Overview & Pedagogical Objectives

This workshop provides an advanced, practical guide to model criticism, diagnostic checking, and convergence troubleshooting for Linear Mixed-Effects Models (LMMs) and Generalized Linear Mixed-Effects Models (GLMMs) using `lme4` and related R packages (`DHARMa`, `performance`, `influence.ME`, `trouBBlme4SolveR`).

### Benchmark Linguistic Datasets (CRC 1252 'Prominence in Language')
Instead of non-linguistic toy examples (e.g. `sleepstudy`), the workshop demonstrates all workflows on authentic linguistic datasets:
1. **`languageR::lexdec` (Baayen et al., 2006)**: Continuous reaction times ($N=1,659$) in visual lexical decision with crossed random factors (`Subject` and `Word`), lexical frequency, word length, native language, and trial order.
2. **`languageR::dative` (Bresnan et al., 2007)**: Discrete syntactic choice ($N=3,263$) in the dative alternation (NP vs. PP), testing prominence hierarchies (animacy, pronominality, givenness, length) with `Verb` random effects.

---

## Curriculum Structure

### Module 1: Design Relaxation, Structural Assumptions & The Singularity Debate (14:00 – 14:15)
- **Relaxing Balanced Design Assumptions**:
  - Comparison of traditional repeated-measures ANOVA (requiring strict balance and sphericity) vs. LMMs/GLMMs handling unbalanced data, missing observations, and complex clustering.
  - **Nested vs. Crossed Random Effects**:
    - Nested designs: e.g., `(1 | Class / Student)` or `(1 | Class) + (1 | Class:Student)`.
    - Crossed designs: e.g., `(1 | Subject) + (1 | Item)`. Failure to account for crossed item-level variation leads to the "language-as-fixed-effect" fallacy and severe Type I error inflation.
  - **Sphericity**: Explaining how mixed models bypass repeated-measures ANOVA sphericity assumptions by directly modeling variance-covariance components and residual correlation structures.
- **The Maximal vs. Parsimonious Random Structure Debate**:
  - **Barr et al. (2013)**: Keep it maximal — include random intercepts and random slopes for all within-unit factors to prevent Type I error inflation.
  - **Bates et al., Matuschek et al., Vasishth**: Parsimonious model selection — complex maximal models frequently lead to overparameterization, loss of power, and singular fits.
  - Reference: Vasishth tutorial on overly simple random effects inflating Type I error.
- **Singularity Mechanics (`isSingular()`)**:
  - Mathematical causes: collapse of variance components to boundary zero ($\sigma_b^2 \approx 0$) or correlation parameters to $\pm 1.0$.
  - Evaluation in `lme4` using `isSingular(model)`.

---

### Module 2: Residual Assumptions & Simulation Diagnostics with DHARMa (14:15 – 14:35)
- **Classical Residual Assumptions in LMMs**:
  1. **Residual Normality**: Q-Q plots, Shapiro-Wilk test (`shapiro.test`), Kolmogorov-Smirnov test (`ks.test`).
  2. **Independence of Errors**: Inspecting autocorrelation using `acf(residuals(m))` and temporal/spatial autocorrelation tests.
  3. **Homoscedasticity (Equal Variance)**: Visual inspection of scale-location plots, formal testing (Levene's test), and handling heteroscedasticity via variance weighting (`weights = varIdent()`).
- **GLMM Residual Failure Modes & DHARMa**:
  - Failure of raw/Pearson residuals in GLMMs (discrete outcomes) due to mean-variance dependencies.
  - Probability Integral Transform (PIT) to create uniform quantile residuals $\mathcal{U}(0,1)$.
  - Executing `DHARMa::simulateResiduals()`, `testDispersion()`, `testZeroInflation()`, and `testTemporalAutocorrelation()`.

---

### Module 3: Multicollinearity, Multi-Panel Checks & Cluster Influence (14:35 – 14:55)
- **Multicollinearity & Variance Inflation Factor (VIF)**:
  - Checking fixed-effect predictor collinearity using `performance::check_collinearity()` or `car::vif()`.
  - VIF thresholds ($VIF > 5$ or $VIF > 10$) and why automated variable dropping can be harmful when controlling for combined effects.
- **Unified Diagnostics**:
  - Comprehensive model checking with `performance::check_model()` (posterior predictive checks, linearity, BLUP normality, homoscedasticity).
- **Cluster-Level Leverage & Influence**:
  - Assessing influential subjects/items using `influence.ME` (Cook's distance, DFBETAS).

---

### Module 4: Convergence Troubleshooting & Optimizer Debugging (14:55 – 15:15)
- **Deconstructing `lme4` Warnings**:
  - Max gradient warnings (`max|grad| > 1e-3`) vs. Degenerate Hessian warnings.
- **Predictor Standardization**:
  - $z$-score scaling of continuous predictors ($\mu=0, \sigma=1$) to resolve elongated deviance valleys.
- **Optimizer Benchmarking & Automation**:
  - Running `lme4::allFit()` to test multiple optimizers (`bobyqa`, `Nelder_Mead`, `nlminbwrap`).
  - Automated troubleshooting using `trouBBlme4SolveR::dwmw()`.

---

### Module 5: Model Comparison, Nakagawa $R^2$, & Open Science Reporting (15:15 – 15:30)
- **Model Comparison Protocols**:
  - REML vs. ML rules: `REML = TRUE` for random-effects comparisons, `REML = FALSE` for fixed-effects Likelihood Ratio Tests (`anova()`).
- **Nakagawa's $R^2$**:
  - Extracting Marginal $R^2_m$ and Conditional $R^2_c$ via `performance::r2_nakagawa()`.
- **Open Science & Reproducibility**:
  - Meteyard & Davies (2020) reporting standards for mixed-effects models.
