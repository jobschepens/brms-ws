# Technical Specification, Methodological Review, and Curriculum Outline for Session 29: lme4 Model Criticism

**Course / Series**: Research Data and Methods Workshop Series  
**Session Title**: Session 29: lme4 Model Criticism & Advanced Mixed-Effects Diagnostics  
**Duration**: 90 Minutes (14:00 – 15:30)  
**Instructor**: Job Schepens  

---

## Workshop Overview & Pedagogical Objectives

This workshop provides an advanced, practical guide to model criticism, diagnostic checking, contrast coding, and convergence troubleshooting for Linear Mixed-Effects Models (LMMs), Generalized Linear Mixed-Effects Models (GLMMs), and Cumulative Link Mixed Models (CLMMs) using `lme4` and modern R packages (`DHARMa`, `emmeans`, `performance`, `influence.ME`, `trouBBlme4SolveR`, `ordinal`).

### Benchmark Linguistic Datasets (CRC 1252 'Prominence in Language')
Instead of non-linguistic toy examples (e.g. `sleepstudy`), the workshop demonstrates all workflows on authentic linguistic datasets:
1. **`languageR::lexdec` (Baayen et al., 2006)**: Continuous reaction times ($N=1,659$) in visual lexical decision with crossed random factors (`Subject` and `Word`), lexical frequency, word length, native language, and trial order.
2. **`languageR::dative` (Bresnan et al., 2007)**: Discrete syntactic choice ($N=3,263$) in the dative alternation (NP vs. PP), testing prominence hierarchies (animacy, pronominality, givenness, length) with `Verb` random effects.
3. **`languageR::sizeRatings`**: Ordinal 7-point Likert scale ratings ($N=3,078$) across 38 subjects and 81 words, evaluating semantic size ratings.

---

## Curriculum Structure

### Module 1: Continuous Reaction Times, Maximal Structure & The Singularity Debate (14:00 – 14:15)
- **Contrast Coding Before Fitting (Schad et al., 2020)**:
  - The hazard of default treatment coding: $\beta$ coefficients become simple effects at baseline; random slopes force intercept variance to baseline, inducing artificial $\rho \approx \pm 1.0$ singular fits.
  - Centered sum contrast coding ($-0.5 / +0.5$): centers random intercept at the grand mean, decouples slope variance, and validates Type III ANOVA tests.
- **Crossed vs. Nested Random Effects**:
  - Crossed designs: `(1 | Subject) + (1 | Word)`. Bypassing Clark's (1973) language-as-fixed-effect fallacy.
- **The Maximal vs. Parsimonious Debate**:
  - Barr et al. (2013) vs. Bates et al. (2015) & Matuschek et al. (2017).
- **Singularity Mechanics & Automated Pruning**:
  - Boundary singularities in `isSingular()` and automated variance pruning with `trouBBlme4SolveR::dwmw()`.

---

### Module 2: Residual Assumptions & Simulation Diagnostics with DHARMa (14:15 – 14:30)
- **Classical LMM Residuals**:
  - Normality (Q-Q plots), homoscedasticity (fitted vs. residuals), and temporal autocorrelation (`Trial`).
- **GLMM Residual Failure Modes & DHARMa**:
  - Why Pearson/deviance residuals fail on binary/Poisson outcomes.
  - Probability Integral Transform (PIT) to create uniform quantile residuals $\mathcal{U}(0,1)$.
  - Formal testing: `testUniformity()`, `testDispersion()`, `testZeroInflation()`, and `testTemporalAutocorrelation()`.

---

### Module 3: Multicollinearity, Multi-Panel Checks & Cluster Influence (14:30 – 14:45)
- **Multicollinearity & VIF**:
  - Variance Inflation Factor (`performance::check_collinearity()`).
- **Multi-Panel Diagnostics**:
  - Posterior predictive checks, linearity, and BLUP normality via `performance::check_model()`.
- **Cluster-Level Leverage & Influence**:
  - Influential subjects and words via `influence.ME` (Cook's distance, DFBETAS).

---

### Module 4: Ordinal & Likert Scale Modeling (14:45 – 15:00)
- **The Fallacy of Naive Gaussian LMMs for Likert Data**:
  - Fitting `lmer(Rating ~ ...)` on 7-point Likert ratings: severe DHARMa Q-Q quantile distortion and boundary truncation.
- **Cumulative Link Mixed Models (`ordinal::clmm`)**:
  - Latent threshold cutpoints ($\theta_1 < \dots < \theta_6$) and proportional odds assumptions.

---

### Module 5: Post-Fitting Inference with emmeans & The Contrast Coding Synthesis (15:00 – 15:15)
- **Estimated Marginal Means**:
  - Balanced reference grids across continuous and categorical factors.
  - Scale of inference: Link scale (log-odds / odds ratios) vs. Response scale (probabilities).
  - Pairwise contrasts, Kenward-Roger degrees-of-freedom, and Tukey multiplicity adjustments.
- **The Two-Stage Principle: Why Both Contrast Coding and emmeans Are Necessary**:
  - *A priori (Contrast Coding)*: Parameterizes design matrix $\mathbf{X}$, prevents random slope singularities, makes $\beta$ interpretable as main effects, validates Type III ANOVA.
  - *Post hoc (emmeans)*: Evaluates balanced reference grid predictions, slices interactions (`pairwise ~ A | B`), computes delta-method standard errors on response scale.

---

### Module 6: Optimizer Benchmarking, Variance Partitioning & Reporting (15:15 – 15:30)
- **Optimizer Benchmarking**:
  - Testing multiple algorithms via `lme4::allFit()`.
- **Model Comparison Protocols**:
  - REML vs. ML rules: `REML = TRUE` for random-effects comparisons, `REML = FALSE` for fixed-effects Likelihood Ratio Tests (`anova()`).
- **Variance Partitioning & Reporting**:
  - Nakagawa's Marginal ($R^2_m$) and Conditional ($R^2_c$) metrics.
  - Meteyard & Davies (2020) reporting standards for open science.
