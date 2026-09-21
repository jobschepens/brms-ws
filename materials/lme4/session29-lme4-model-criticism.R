# ==============================================================================
# Session 29: lme4 Model Criticism & Advanced Mixed-Effects Diagnostics
# Research Data and Methods Workshop Series (CRC 1252 "Prominence in Language")
# Speaker: Job Schepens | Date: 2026-09-30
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Environment Setup & Libraries
# ------------------------------------------------------------------------------
library(lme4)
library(lmerTest)
library(DHARMa)
library(performance)
library(see)
library(influence.ME)
library(trouBBlme4SolveR)
library(dfoptim)
library(languageR)
library(ordinal)
library(emmeans)
library(tidyverse)

set.seed(12345)
theme_set(theme_minimal(base_size = 12))

# ------------------------------------------------------------------------------
# Module 1: Continuous RT, Maximal Structure & The Need for Contrast Coding
# ------------------------------------------------------------------------------
data(lexdec)

# Contrast Coding Rationale:
# In R, factors default to treatment (dummy) coding (0, 1). In mixed models:
# 1. Lower-order effects become simple effects at baseline when interactions exist.
# 2. Random slopes (1 + Factor | Group) tie intercept variance to baseline, inducing
#    artificial correlation (rho = +/- 1.0) and boundary singular fits.
# Centered sum coding (-0.5 / +0.5) centers the intercept at the grand mean,
# decouples intercept and slope variance, and makes coefficients true main effects.
lexdec <- lexdec %>%
  mutate(
    Freq_z   = as.numeric(scale(Frequency)),
    Length_z = as.numeric(scale(Length)),
    Native_num = ifelse(NativeLanguage == "Other", 0.5, -0.5),
    Sex_num    = ifelse(Sex == "M", 0.5, -0.5)
  )

# Fit maximal crossed random-effects model (Barr et al., 2013)
m_maximal <- lmer(
  RT ~ Freq_z + Length_z + Native_num + Sex_num +
    (1 + Freq_z + Length_z | Subject) +
    (1 + Native_num + Sex_num | Word),
  data = lexdec
)
cat("Is maximal model singular?", isSingular(m_maximal), "\n")
print(VarCorr(m_maximal))

# Automated singular fit resolution with trouBBlme4SolveR (Ben Bolker)
m_resolved <- dwmw(m_maximal)
cat("Is resolved model singular?", isSingular(m_resolved), "\n")

# Parsimonious random-effects model (Bates et al., 2015)
m_parsimonious <- lmer(
  RT ~ Freq_z + Length_z + Native_num + (1 + Freq_z | Subject) + (1 | Word),
  data = lexdec
)
cat("Is parsimonious model singular?", isSingular(m_parsimonious), "\n")

# ------------------------------------------------------------------------------
# Module 2: Residual Diagnostics & DHARMa Simulations
# ------------------------------------------------------------------------------
# Classical Gaussian LMM residual inspection
par(mfrow = c(1, 2))
qqnorm(residuals(m_parsimonious), main = "Normal Q-Q Plot (LMM)")
qqline(residuals(m_parsimonious), col = "red", lwd = 2)
plot(fitted(m_parsimonious), residuals(m_parsimonious),
     xlab = "Fitted Values (log RT)", ylab = "Residuals", main = "Residuals vs Fitted")
abline(h = 0, col = "red", lty = 2)
par(mfrow = c(1, 1))

# Discrete Prominence GLMM: English Dative Alternation (Bresnan et al., 2007)
data(dative)
m_dative <- glmer(
  RealizationOfRecipient ~ AnimacyOfRec + PronomOfRec + LengthOfTheme + (1 | Verb),
  family = binomial,
  data = dative
)

# DHARMa simulation-based quantile residuals
sim_dative <- simulateResiduals(fittedModel = m_dative, n = 500, plot = FALSE)
plot(sim_dative)

# Formal DHARMa tests
print(testUniformity(sim_dative))
print(testDispersion(sim_dative))
print(testZeroInflation(sim_dative))

# Temporal autocorrelation across experimental trials (aggregated across subjects)
sim_lexdec <- simulateResiduals(fittedModel = m_parsimonious, n = 250, plot = FALSE)
sim_trial <- recalculateResiduals(sim_lexdec, group = lexdec$Trial)
print(testTemporalAutocorrelation(sim_trial, time = unique(lexdec$Trial)))

# ------------------------------------------------------------------------------
# Module 3: Multicollinearity, Multi-Panel Checks & Cluster Influence
# ------------------------------------------------------------------------------
# Multicollinearity (VIF)
vif_res <- check_collinearity(m_parsimonious)
print(vif_res)
plot(vif_res)

# Multi-panel model checks
check_model(m_parsimonious)

# Subject-level Cook's Distance
infl_subj <- influence(m_parsimonious, group = "Subject", count = FALSE)
plot(infl_subj, which = "cook", cutoff = 4 / length(unique(lexdec$Subject)),
     main = "Subject-Level Cook's Distance")

# Word-level Cook's Distance (Item outliers)
infl_word <- influence(m_parsimonious, group = "Word", count = FALSE)
plot(infl_word, which = "cook", cutoff = 4 / length(unique(lexdec$Word)),
     main = "Word-Level Cook's Distance (Items)")

# ------------------------------------------------------------------------------
# Module 4: Ordinal & Likert Scale Modeling (sizeRatings)
# ------------------------------------------------------------------------------
data(sizeRatings)

# 1. Naive Gaussian LMM (violates boundary and discrete scale assumptions)
m_naive_likert <- lmer(Rating ~ Class + (1 | Word), data = sizeRatings)
sim_naive <- simulateResiduals(m_naive_likert, n = 250, plot = FALSE)
plot(sim_naive)

# 2. Cumulative Link Mixed Model (Christensen, 2019)
sizeRatings <- sizeRatings %>%
  mutate(Rating_ord = factor(Rating, ordered = TRUE))

m_clmm <- clmm(Rating_ord ~ Class + (1 | Word), data = sizeRatings)
print(summary(m_clmm))

# ------------------------------------------------------------------------------
# Module 5: Post-Fitting Inference with emmeans & Contrast Coding Synthesis
# ------------------------------------------------------------------------------
# 5.1 Demonstrating Coding Invariance of emmeans
# Fit model with default treatment coding vs centered sum coding
m_treatment <- lmer(RT ~ Freq_z * NativeLanguage + (1 | Subject), data = lexdec)
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
emm_dative <- emmeans(m_dative, ~ AnimacyOfRec, type = "response")
print(emm_dative)
print(pairs(emm_dative))

# CLMM: Latent linear predictor contrasts
emm_clmm <- emmeans(m_clmm, ~ Class)
print(emm_clmm)
print(pairs(emm_clmm))

# ------------------------------------------------------------------------------
# Module 6: Optimizer Benchmarking, Variance Partitioning & Reporting
# ------------------------------------------------------------------------------
# Benchmark across all optimizers
all_fits <- allFit(m_parsimonious)
print(summary(all_fits))

# Likelihood Ratio Test under Maximum Likelihood (REML = FALSE)
m_full_ml <- lmer(RT ~ Freq_z + Length_z + Native_num + (1 | Subject) + (1 | Word),
                  data = lexdec, REML = FALSE)
m_null_ml <- lmer(RT ~ Length_z + Native_num + (1 | Subject) + (1 | Word),
                  data = lexdec, REML = FALSE)
print(anova(m_null_ml, m_full_ml))

# Variance partitioning: Marginal vs Conditional R2 (Nakagawa et al.)
r2_val <- r2_nakagawa(m_resolved)
print(r2_val)

cat("\n=== All diagnostic workflows executed successfully! ===\n")
