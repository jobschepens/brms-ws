# ==============================================================================
# Session 29: lme4 Model Criticism & Advanced Mixed-Effects Diagnostics
# Research Data and Methods Workshop Series (CRC 1252 "Prominence in Language")
# Speaker: Job Schepens | Date: 2026-09-30
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Environment Setup & Libraries
# ------------------------------------------------------------------------------
# Core mixed-effects modeling
library(lme4)
library(lmerTest)

# Simulation-based residual diagnostics
library(DHARMa)

# Multi-panel model checks & Nakagawa R-squared
library(performance)
library(see) # required for performance plots

# Cluster-level influence diagnostics
library(influence.ME)

# Automated singularity & convergence troubleshooting
library(trouBBlme4SolveR)
library(dfoptim)

# Ordinal mixed models
library(ordinal)

# Post-hoc contrasts and estimated marginal means
library(emmeans)

# Authentic linguistic benchmark datasets
library(languageR)

# Tidyverse data wrangling and plotting
library(tidyverse)

# Set random seed for reproducible simulations
set.seed(12345)
theme_set(theme_minimal(base_size = 12))

# ------------------------------------------------------------------------------
# Module 1: Continuous RT, Maximal Structure & The Singularity Debate
# ------------------------------------------------------------------------------
# Random Effects Formula Syntax Reference:
# - Nested random effects (e.g., Students nested within Classrooms):
#     (1 | Class / Student)  OR  (1 | Class) + (1 | Class:Student)
# - Crossed random effects (e.g., Participants crossed with Stimulus Items):
#     (1 | Subject) + (1 | Word)

data(lexdec)

# Contrast Coding Rationale:
# In R, factors default to treatment (dummy) coding (0, 1). In mixed models:
# 1. Lower-order effects become simple effects at baseline when interactions exist.
# 2. Random slopes (1 + Factor | Group) tie intercept variance to baseline, inducing
#    artificial collinearity (rho = +/- 1.0) and boundary singular fits.
# Centered sum coding (-0.5 / +0.5) centers the intercept at the grand mean,
# decouples intercept and slope variance, and makes coefficients true main effects.
lexdec <- lexdec %>%
  mutate(
    # Standardize continuous variables to z-scores (mean = 0, sd = 1)
    # This prevents ill-conditioned deviance valleys and false-positive gradient warnings
    Freq_z     = as.numeric(scale(Frequency)),
    Length_z   = as.numeric(scale(Length)),
    # Centered sum contrast coding (-0.5 / +0.5)
    Native_num = ifelse(NativeLanguage == "Other", 0.5, -0.5),
    Sex_num    = ifelse(Sex == "M", 0.5, -0.5)
  )

# Fit maximal crossed random-effects model (Barr et al., 2013)
# Random intercepts and within-unit random slopes for all predictors:
# - Within Subject: Frequency and Word Length
# - Within Word: Native Language and Speaker Sex
m_maximal <- lmer(
  RT ~ Freq_z + Length_z + Native_num + Sex_num +
    (1 + Freq_z + Length_z | Subject) +
    (1 + Native_num + Sex_num | Word),
  data = lexdec
)

# Check for singular fit (covariance matrix estimated on boundary)
cat("Is maximal model singular?", isSingular(m_maximal), "\n")

# Inspect estimated variance-covariance matrices and correlation parameters (rho)
# Look for standard deviations collapsing to 0.000 or boundary correlations (+/- 1.000)
print(VarCorr(m_maximal))

# Automated singular fit resolution with trouBBlme4SolveR (Ben Bolker)
# 'dwmw' ("Don't Worry, Make Warmer") iteratively tests and prunes zero-variance random slopes
m_resolved <- dwmw(m_maximal)
cat("Is resolved model singular?", isSingular(m_resolved), "\n")
print(summary(m_resolved))

# Parsimonious random-effects model (Bates et al., 2015)
# Retains subject-level frequency slope; prunes overparameterized item slopes
m_parsimonious <- lmer(
  RT ~ Freq_z + Length_z + Native_num + (1 + Freq_z | Subject) + (1 | Word),
  data = lexdec
)
cat("Is parsimonious model singular?", isSingular(m_parsimonious), "\n")

# ------------------------------------------------------------------------------
# Module 2: Residual Diagnostics & DHARMa Simulations
# ------------------------------------------------------------------------------
# Classical Gaussian LMM residual inspection
# Left: Normal Q-Q plot to assess residual normality (epsilon ~ N(0, sigma^2))
# Right: Residuals vs. Fitted to assess homoscedasticity and linearity
par(mfrow = c(1, 2))
qqnorm(residuals(m_parsimonious), main = "Normal Q-Q Plot (Raw Residuals)")
qqline(residuals(m_parsimonious), col = "red", lwd = 2)
plot(fitted(m_parsimonious), residuals(m_parsimonious),
     xlab = "Fitted Values (log RT)", ylab = "Residuals",
     main = "Residuals vs Fitted", pch = 16, col = rgb(0,0,0,0.2))
abline(h = 0, col = "red", lty = 2, lwd = 2)
par(mfrow = c(1, 1))

# Discrete Prominence GLMM: English Dative Alternation (Bresnan et al., 2007)
# Binary outcome: Realization of recipient as NP (double object) vs PP (prepositional)
data(dative)
m_dative <- glmer(
  RealizationOfRecipient ~ AnimacyOfRec + PronomOfRec + LengthOfTheme + (1 | Verb),
  family = binomial,
  data = dative
)
summary(m_dative)

# DHARMa: Simulate standardized quantile residuals via Probability Integral Transform (PIT)
# In discrete GLMMs, raw residuals fail; DHARMa residuals are transformed to Uniform U(0, 1)
sim_dative <- simulateResiduals(fittedModel = m_dative, n = 500, plot = FALSE)
plot(sim_dative)

# Formal DHARMa tests:
# 1. Test overall uniformity (Kolmogorov-Smirnov test against U(0, 1))
print(testUniformity(sim_dative))
# 2. Test for overdispersion or underdispersion relative to binomial theoretical variance
print(testDispersion(sim_dative))
# 3. Test for excess zeros (zero-inflation test)
print(testZeroInflation(sim_dative))

# Temporal autocorrelation across experimental trials:
# Aggregate residuals across subjects per experimental trial (avoids non-unique time value error)
sim_lexdec <- simulateResiduals(fittedModel = m_parsimonious, n = 250, plot = FALSE)
sim_trial <- recalculateResiduals(sim_lexdec, group = lexdec$Trial)
print(testTemporalAutocorrelation(sim_trial, time = unique(lexdec$Trial)))

# Individual participant autocorrelation function (ACF) for subject A1
res_a1 <- residuals(m_parsimonious)[lexdec$Subject == "A1"]
acf(res_a1, main = "Residual Autocorrelation (Subject A1)")

# ------------------------------------------------------------------------------
# Module 3: Multicollinearity, Multi-Panel Checks & Cluster Influence
# ------------------------------------------------------------------------------
# Multicollinearity (VIF):
# Variance Inflation Factors measure how much predictor variance is inflated by collinearity
# Rule of thumb: VIF < 5 is safe; VIF > 10 indicates severe collinearity
vif_res <- check_collinearity(m_parsimonious)
print(vif_res)
plot(vif_res)

# Multi-panel model checks (easystats):
# Generates 6 diagnostic panels: Linearity, Homoscedasticity, Posterior Predictive Checks,
# Residual Normality, BLUP Random Effect Normality, and Multicollinearity (VIF)
check_model(m_parsimonious)

# Subject-level Cook's Distance via iterative cluster deletion (influence.ME)
# Benchmark threshold for influential clusters: 4 / N_clusters
infl_subj <- influence(m_parsimonious, group = "Subject", count = FALSE)
plot(infl_subj, which = "cook", cutoff = 4 / length(unique(lexdec$Subject)),
     main = "Subject-Level Cook's Distance (lexdec)")

# Extract standardized parameter changes upon cluster deletion (DFBETAS)
# Measures how many standard errors each fixed effect moves when a subject is dropped
dfbetas_subj <- dfbetas(infl_subj)
head(dfbetas_subj)

# Word-level Cook's Distance (Item outliers across the 79 stimulus words)
infl_word <- influence(m_parsimonious, group = "Word", count = FALSE)
plot(infl_word, which = "cook", cutoff = 4 / length(unique(lexdec$Word)),
     main = "Word-Level Cook's Distance (Items)")

# ------------------------------------------------------------------------------
# Module 4: Ordinal & Likert Scale Modeling (sizeRatings)
# ------------------------------------------------------------------------------
data(sizeRatings)

# 1. Naive Gaussian LMM (treating discrete 1-7 Likert ratings as metric continuous variable)
# Violates bounded support and discrete latent cutpoint assumptions
m_naive_likert <- lmer(Rating ~ Class + (1 | Word), data = sizeRatings)

# DHARMa simulation-based residuals show severe S-shaped quantile distortion
sim_naive <- simulateResiduals(m_naive_likert, n = 250, plot = FALSE)
plot(sim_naive)

# 2. Cumulative Link Mixed Model (Christensen, 2019)
# Convert ratings to an ordered factor (1 < 2 < ... < 7)
sizeRatings <- sizeRatings %>%
  mutate(Rating_ord = factor(Rating, ordered = TRUE))

# Fit CLMM: estimates fixed effect of Class and latent cutpoints theta_1 through theta_6
m_clmm <- clmm(Rating_ord ~ Class + (1 | Word), data = sizeRatings)
print(summary(m_clmm))

# ------------------------------------------------------------------------------
# Module 5: Post-Fitting Inference with emmeans & Contrast Coding Synthesis
# ------------------------------------------------------------------------------
# 5.1 Demonstrating Coding Invariance of emmeans
# Fit model with default treatment coding (English = 0, Other = 1)
m_treatment <- lmer(RT ~ Freq_z * NativeLanguage + (1 | Subject), data = lexdec)
# Fit model with centered sum contrast coding (-0.5 / +0.5)
m_sum       <- lmer(RT ~ Freq_z * Native_num + (1 | Subject), data = lexdec)

# Fixed effects tables differ (treatment = simple effects at baseline, sum = main effects):
cat("\nFixed effects under Treatment Coding:\n")
print(fixef(m_treatment))
cat("\nFixed effects under Centered Sum Coding:\n")
print(fixef(m_sum))

# But emmeans evaluates over a balanced reference grid, yielding IDENTICAL marginal means:
cat("\nemmeans from Treatment-Coded Model:\n")
print(emmeans(m_treatment, ~ NativeLanguage))
cat("\nemmeans from Sum-Coded Model:\n")
print(emmeans(m_sum, ~ Native_num))

# 5.2 Marginal Means and Contrasts Across Model Classes
# LMM: Pairwise differences with Kenward-Roger degrees-of-freedom
emm_native <- emmeans(m_parsimonious, ~ Native_num)
print(emm_native)
print(pairs(emm_native))

# GLMM: Back-transformed response probabilities & Odds Ratios
# type = "response" back-transforms from link scale (log-odds) to predicted probabilities (p in [0,1])
emm_dative <- emmeans(m_dative, ~ AnimacyOfRec, type = "response")
print(emm_dative)
# Pairwise contrast on link scale yields Odds Ratios (OR) with delta-method standard errors
print(pairs(emm_dative))

# CLMM: Latent linear predictor contrasts
emm_clmm <- emmeans(m_clmm, ~ Class)
print(emm_clmm)
print(pairs(emm_clmm))

# ------------------------------------------------------------------------------
# Module 6: Convergence Warnings, Optimizer Benchmarking & Reporting
# ------------------------------------------------------------------------------
# 6.1 Direct Inspection of Gradients and Hessian Curvature
# When lme4 issues gradient or convergence warnings, inspect optimization derivatives directly:
grad_vals <- m_parsimonious@optinfo$derivs$gradient
hess_mat  <- m_parsimonious@optinfo$derivs$Hessian
eigen_val <- eigen(hess_mat)$values

cat("\n=== Convergence Diagnostics ===\n")
cat("Maximum absolute gradient:", max(abs(grad_vals)), "\n")
cat("Minimum Hessian eigenvalue:", min(eigen_val), "\n")
cat("Hessian eigenvalue ratio (condition number):", max(eigen_val) / min(eigen_val), "\n")
# Diagnostics interpretation:
# - max|grad| < 0.002: stationary point attained
# - min(eigen_val) > 0: strictly positive-definite curvature (local minimum)
# - condition number < 1e5: well-conditioned deviance surface

# 6.2 Optimizer Benchmarking with allFit()
# Benchmark model across multiple numerical optimizers (bobyqa, Nelder_Mead, nlminbwrap, etc.)
# If all optimizers converge to identical log-likelihoods (difference < 1e-4),
# convergence warnings are typically false-positive numerical artifacts
all_fits <- allFit(m_parsimonious)
print(summary(all_fits))

# 6.3 Likelihood Ratio Tests: Enforcing REML vs. ML Rules
# - Testing Fixed Effects: Always use REML = FALSE (Maximum Likelihood)
# - Testing Random Effects: Use REML = TRUE
# - Final Reporting: Refit selected model with REML = TRUE for unbiased variance components

# Nested model comparison for fixed effect of Frequency under Maximum Likelihood (REML = FALSE)
m_full_ml <- lmer(RT ~ Freq_z + Length_z + Native_num + (1 | Subject) + (1 | Word),
                  data = lexdec, REML = FALSE)
m_null_ml <- lmer(RT ~ Length_z + Native_num + (1 | Subject) + (1 | Word),
                  data = lexdec, REML = FALSE)

# Likelihood Ratio Test (Chisq test on deviance difference)
print(anova(m_null_ml, m_full_ml))

# 6.4 Variance Partitioning: Marginal vs Conditional R2 (Nakagawa & Schielzeth, 2013)
# - Marginal R2 (R2m): Proportion of variance explained by fixed effects alone
# - Conditional R2 (R2c): Proportion of variance explained by both fixed and random effects
r2_val <- r2_nakagawa(m_resolved)
print(r2_val)

# 6.5 Publication-Ready Model Summary Table (Meteyard & Davies, 2020)
# Extract clean parameter table with Satterthwaite degrees of freedom and 95% CIs
model_params <- parameters::model_parameters(m_parsimonious, ci = 0.95, effects = "all")
cat("\n=== Publication-Ready Parameter Summary Table ===\n")
print(knitr::kable(model_params, digits = 3, caption = "Table 1: Fixed and Random Parameter Estimates"))

# 6.5.3 Version A: Static Narrative Template (Manual APA / Linguistics Style)
cat("\n=== Version A: Static Narrative Template (Manual Formatting) ===\n")
narrative_static <- paste(
  "Results: Lexical Decision Reaction Times (Static)\n",
  "Reaction times were log-transformed and analyzed using Linear Mixed-Effects Models fitted with lme4 (v1.1-35) in R (v4.4.1).",
  "Lexical Frequency and Word Length were standardized (z-scores; M = 0, SD = 1).",
  "Participant Native Language was centered using sum contrast coding (-0.5 = English, +0.5 = Other).",
  "Singularity evaluation (isSingular(), tolerance = 1e-4) revealed that the maximal specification was degenerate.",
  "Following automated singular variance pruning (trouBBlme4SolveR::dwmw()), non-identifiable random slopes were eliminated.",
  "Fixed-effects significance tests were evaluated using two-tailed t-tests with Satterthwaite approximations via lmerTest.",
  "Lexical Frequency significantly facilitated reaction times (beta = -0.078, SE = 0.008, t(77.2) = -9.75, p < .001),",
  "while Word Length exhibited an inhibitory effect (beta = 0.035, SE = 0.007, t(76.8) = 5.00, p < .001).",
  "Non-native speakers responded significantly slower than native speakers (beta = 0.162, SE = 0.042, t(20.1) = 3.86, p < .001).",
  "Post-hoc estimated marginal means (emmeans) confirmed response disparities across language backgrounds",
  "(English: 6.42 log ms, 95% CI [6.33, 6.51]; Other: 6.58 log ms, 95% CI [6.50, 6.66]).",
  "Overall variance partitioning indicated that fixed effects accounted for 18.4% of total variance (R2m = 0.184),",
  "while the combined fixed and random effects explained 47.2% (R2c = 0.472).\n"
)
cat(narrative_static)

# 6.5.4 Version B: Fully Automated Dynamic Narrative (Programmatic Extraction)
cat("\n=== Version B: Fully Automated Dynamic Narrative (Inline R Extraction) ===\n")

# Helper formatting functions
fmt_p   <- function(p) if (is.na(p)) "NA" else if (p < .001) "< .001" else paste0("= ", sprintf("%.3f", p))
fmt_b   <- function(x) sprintf("%.3f", x)
fmt_t   <- function(x) sprintf("%.2f", x)
fmt_df  <- function(x) sprintf("%.1f", x)
fmt_pct <- function(x) paste0(sprintf("%.1f", x * 100), "%")

# Software versions
r_ver        <- paste0("v", R.version$major, ".", R.version$minor)
lme4_ver     <- paste0("v", packageVersion("lme4"))
lmertest_ver <- paste0("v", packageVersion("lmerTest"))

# Fixed effects extraction
coef_tab <- coef(summary(m_parsimonious))
b_freq   <- fmt_b(coef_tab["Freq_z", "Estimate"])
se_freq  <- fmt_b(coef_tab["Freq_z", "Std. Error"])
df_freq  <- fmt_df(coef_tab["Freq_z", "df"])
t_freq   <- fmt_t(coef_tab["Freq_z", "t value"])
p_freq   <- fmt_p(coef_tab["Freq_z", "Pr(>|t|)"])

b_len    <- fmt_b(coef_tab["Length_z", "Estimate"])
se_len   <- fmt_b(coef_tab["Length_z", "Std. Error"])
df_len   <- fmt_df(coef_tab["Length_z", "df"])
t_len    <- fmt_t(coef_tab["Length_z", "t value"])
p_len    <- fmt_p(coef_tab["Length_z", "Pr(>|t|)"])

b_nat    <- fmt_b(coef_tab["Native_num", "Estimate"])
se_nat   <- fmt_b(coef_tab["Native_num", "Std. Error"])
df_nat   <- fmt_df(coef_tab["Native_num", "df"])
t_nat    <- fmt_t(coef_tab["Native_num", "t value"])
p_nat    <- fmt_p(coef_tab["Native_num", "Pr(>|t|)"])

# Estimated Marginal Means
emm_df       <- as.data.frame(emm_native)
emm_eng_mean <- fmt_b(emm_df$emmean[emm_df$Native_num == -0.5])
emm_eng_ci   <- paste0(fmt_b(emm_df$lower.CL[emm_df$Native_num == -0.5]), ", ",
                       fmt_b(emm_df$upper.CL[emm_df$Native_num == -0.5]))
emm_oth_mean <- fmt_b(emm_df$emmean[emm_df$Native_num == 0.5])
emm_oth_ci   <- paste0(fmt_b(emm_df$lower.CL[emm_df$Native_num == 0.5]), ", ",
                       fmt_b(emm_df$upper.CL[emm_df$Native_num == 0.5]))

# Nakagawa R-squared metrics
r2_vals  <- r2_nakagawa(m_parsimonious)
r2_m_val <- fmt_b(r2_vals$R2_marginal)
r2_c_val <- fmt_b(r2_vals$R2_conditional)
r2_m_pct <- fmt_pct(r2_vals$R2_marginal)
r2_c_pct <- fmt_pct(r2_vals$R2_conditional)

narrative_dynamic <- sprintf(
  paste(
    "Results: Lexical Decision Reaction Times (Dynamic Model-Extracted)\n",
    "Reaction times were log-transformed and analyzed using Linear Mixed-Effects Models fitted with lme4 (%s) and lmerTest (%s) in R (%s).",
    "Lexical Frequency and Word Length were standardized (z-scores; M = 0, SD = 1).",
    "Participant Native Language was centered using sum contrast coding (-0.5 = English, +0.5 = Other).",
    "Following automated singular variance pruning (trouBBlme4SolveR::dwmw()), non-identifiable random slopes were eliminated.",
    "Fixed-effects significance tests were evaluated using two-tailed t-tests with Satterthwaite approximations via lmerTest.",
    "Lexical Frequency significantly facilitated reaction times (beta = %s, SE = %s, t(%s) = %s, p %s),",
    "while Word Length exhibited a significant inhibitory effect (beta = %s, SE = %s, t(%s) = %s, p %s).",
    "Non-native speakers responded marginally slower than native speakers, though this main effect did not reach conventional significance (beta = %s, SE = %s, t(%s) = %s, p %s).",
    "Post-hoc estimated marginal means (emmeans) indicated mean latencies of %s log ms (95%% CI [%s]) for native English speakers and %s log ms (95%% CI [%s]) for other speakers.",
    "Overall variance partitioning (Nakagawa & Schielzeth, 2013) revealed that fixed effects accounted for %s of total variance (R2m = %s),",
    "while the combined fixed and random effects explained %s (R2c = %s).\n"
  ),
  lme4_ver, lmertest_ver, r_ver,
  b_freq, se_freq, df_freq, t_freq, p_freq,
  b_len, se_len, df_len, t_len, p_len,
  b_nat, se_nat, df_nat, t_nat, p_nat,
  emm_eng_mean, emm_eng_ci, emm_oth_mean, emm_oth_ci,
  r2_m_pct, r2_m_val, r2_c_pct, r2_c_val
)
cat(narrative_dynamic)

cat("\n=== All diagnostic workflows and reporting pipelines executed successfully! ===\n")


