# Grammaticality Judgment Example: Prior Predictive Checks
# ==========================================================
# This script demonstrates how to validate priors for a Bayesian binary model
# before fitting to data.

library(brms)
library(tidyverse)

# Setup: Create example grammaticality judgment data
set.seed(42)
n_subj <- 25
n_trials <- 40
n_items <- 30

gram_data <- expand.grid(
  trial = 1:n_trials,
  subject = 1:n_subj,
  item = 1:n_items
) %>%
  filter(row_number() <= n_subj * n_trials * 2) %>%  # Balanced design
  mutate(
    condition = rep(c("A", "B"), length.out = n()),
    # Generate binary outcomes: condition B is slightly more acceptable
    p_correct = plogis(0.2 + (condition == "B") * 0.4),
    correct = rbinom(n(), size = 1, prob = p_correct)
  )

# Define priors for binary model
gram_priors <- c(
  prior(normal(0, 1.5), class = Intercept),        # ~50% baseline accuracy
  prior(normal(0, 1), class = b),                  # moderate effects expected
  prior(exponential(1), class = sd),               # between-subject variation
  prior(lkj(2), class = cor)                       # correlations
)

# ============================================================================
# 1. Prior predictive checks for binary data
# ============================================================================
cat("\n=== 1. Fitting model with PRIOR ONLY (no data) ===\n")

# Check if saved model exists to avoid recompiling
model_file <- "materials/scripts/fits/prior_pred_gram.rds"
if (file.exists(model_file)) {
  cat("Loading saved model from:", model_file, "\n")
  prior_pred_gram <- readRDS(model_file)
} else {
  cat("Fitting new model (this may take a while)...\n")
  prior_pred_gram <- brm(
    correct ~ condition + (1 + condition | subject) + (1 | item),
    data = gram_data, 
    family = bernoulli(),
    prior = gram_priors,
    sample_prior = "only",  # Only sample from prior!
    chains = 4, iter = 1000,  # 4 chains, fewer iterations
    cores = 4,                 # Parallel sampling
    verbose = FALSE,
    refresh = 0
  )
  # Save the model for future use
  dir.create("materials/scripts/fits", showWarnings = FALSE, recursive = TRUE)
  saveRDS(prior_pred_gram, model_file)
  cat("Model saved to:", model_file, "\n")
}

cat("Prior predictive model ready.\n")

# Visual checks - for binary data, use different plot types
cat("\nGenerating prior predictive checks...\n")
dir.create("materials/scripts/figures", showWarnings = FALSE, recursive = TRUE)
pdf("materials/scripts/figures/02_prior_predictive_checks_gram_visuals.pdf", width = 12, height = 8)

par(mfrow = c(2, 2))

# Mean comparison (proportion of 1's)
plot(pp_check(prior_pred_gram, type = "stat", stat = "mean", prefix = "ppd"),
     main = "Test stat: Accuracy (proportion correct)")

# Bar plot for discrete outcomes (no prefix for bars)
plot(pp_check(prior_pred_gram, type = "bars", ndraws = 100),
     main = "Bar plot: Observed vs predicted counts")

# Histogram of simulated datasets (no prefix for hist)
plot(pp_check(prior_pred_gram, type = "hist", ndraws = 8),
     main = "Histograms: Simulated data from prior")

# Tabulate observed vs prior predictions
prior_pred_samples <- posterior_predict(prior_pred_gram, ndraws = 1000)
obs_acc <- mean(gram_data$correct)
pred_acc <- apply(prior_pred_samples, 1, mean)

plot(density(pred_acc), 
     main = "Prior predictive distribution of accuracy",
     xlab = "Proportion correct",
     lwd = 2, col = "darkblue")
abline(v = obs_acc, col = "red", lwd = 2, lty = 2)
legend("topright", c("Prior predictive", "Observed"), 
       col = c("darkblue", "red"), lwd = 2, lty = c(1, 2))

dev.off()
cat("Saved: materials/scripts/figures/02_prior_predictive_checks_gram_visuals.pdf\n")

# ============================================================================
# 2. Check prior predictive distribution directly
# ============================================================================
cat("\n=== 2. Examining prior distributions directly ===\n")

# Extract prior samples (use as_draws_df since sample_prior = "only")
prior_samples <- as_draws_df(prior_pred_gram)

# Check Intercept prior
cat("\nIntercept prior (log-odds scale):\n")
intercept_logodds <- quantile(prior_samples$b_Intercept, c(0.025, 0.5, 0.975), na.rm = TRUE)
print(intercept_logodds)

cat("\nIntercept prior (probability scale):\n")
intercept_prob <- plogis(intercept_logodds)
print(intercept_prob)
cat("Interpretation: Prior expects", 
    round(intercept_prob[1]*100), "-", round(intercept_prob[3]*100), 
    "% baseline accuracy (median", round(intercept_prob[2]*100), "%)\n")

# Check effect size prior
cat("\nCondition effect prior (log-odds scale):\n")
effect_logodds <- quantile(prior_samples$b_conditionB, c(0.025, 0.5, 0.975), na.rm = TRUE)
print(effect_logodds)

cat("\nCondition effect prior (multiplicative scale):\n")
print(exp(effect_logodds))
cat("Interpretation: Condition B multiplies odds by", 
    round(exp(effect_logodds[2]), 2), "on average\n")

# Check if prior predictions are reasonable
cat("\nPrior accuracy over all data:\n")
cat("Mean:", round(mean(prior_pred_samples), 3), "\n")
cat("Median:", round(median(apply(prior_pred_samples, 1, mean)), 3), "\n")
cat("Should be close to 0.5 if prior is centered at 0\n")

# ============================================================================
# 3. Check random effect distributions
# ============================================================================
cat("\n=== 3. Checking random effect distributions ===\n")
cat("For prior predictive checks, we examine the IMPLIED distribution\n")
cat("of subject-specific parameters by extracting hyperprior SDs\n")
cat("and simulating random effects.\n")

# Extract hyperprior SDs from prior samples
sd_subject_intercept <- prior_samples$sd_subject__Intercept
sd_subject_slope <- prior_samples$sd_subject__conditionB

# Check subject random intercepts
cat("\nSubject random intercept SD prior:\n")
print(quantile(sd_subject_intercept, c(0.025, 0.5, 0.975), na.rm = TRUE))

# Simulate random effects from this prior
set.seed(123)
n_sims <- 1000
simulated_intercepts <- rnorm(n_sims, mean = 0, sd = median(sd_subject_intercept))

cat("\nImplied subject random intercepts (log-odds scale):\n")
subject_intercepts <- quantile(simulated_intercepts, c(0.025, 0.5, 0.975))
print(subject_intercepts)

cat("\nImplied subject-specific accuracy (probability scale):\n")
intercept_median <- median(prior_samples$b_Intercept)
subject_prob <- plogis(intercept_median + subject_intercepts)
print(subject_prob)
cat("Interpretation: Prior implies subject accuracy ranges from", 
    round(subject_prob[1]*100), "% to", round(subject_prob[3]*100), "%\n")

# Check subject random slopes
cat("\nSubject random slope SD prior:\n")
print(quantile(sd_subject_slope, c(0.025, 0.5, 0.975), na.rm = TRUE))

simulated_slopes <- rnorm(n_sims, mean = 0, sd = median(sd_subject_slope))

cat("\nImplied subject random slopes (log-odds scale):\n")
subject_slopes <- quantile(simulated_slopes, c(0.025, 0.5, 0.975))
print(subject_slopes)

cat("\nInterpretation: Condition effect varies by subject\n")
cat("Weak effect subjects (2.5%): ", round(exp(subject_slopes[1]), 2), "× odds multiplier\n")
cat("Average effect subjects (50%): ", round(exp(subject_slopes[2]), 2), "× odds multiplier\n")
cat("Strong effect subjects (97.5%): ", round(exp(subject_slopes[3]), 2), "× odds multiplier\n")

# Visualize distributions
pdf("materials/scripts/figures/02_prior_predictive_checks_gram_ranef.pdf", width = 12, height = 8)

par(mfrow = c(2, 2))

# Visualize simulated random intercepts
hist(simulated_intercepts, 
     main = "Prior-implied subject random intercepts",
     xlab = "Intercept adjustment (log-odds scale)",
     breaks = 30, col = "skyblue", border = "white")

# Visualize simulated random slopes
hist(simulated_slopes,
     main = "Prior-implied subject random slopes",
     xlab = "Condition effect adjustment (log-odds scale)",
     breaks = 30, col = "lightcoral", border = "white")

# Visualize hyperprior SDs
hist(sd_subject_intercept,
     main = "Hyperprior: SD of random intercepts",
     xlab = "SD value",
     breaks = 30, col = "lightgreen", border = "white")

# Density plot comparing intercepts and slopes
plot(density(simulated_intercepts),
     main = "Prior-implied random effects distributions",
     xlab = "Effect size (log-odds scale)",
     col = "blue", lwd = 2, xlim = range(c(simulated_intercepts, simulated_slopes)),
     ylim = c(0, max(density(simulated_intercepts)$y, density(simulated_slopes)$y)))
lines(density(simulated_slopes),
      col = "red", lwd = 2)
legend("topright", c("Intercepts", "Slopes"), col = c("blue", "red"), lwd = 2)

dev.off()
cat("Saved: materials/scripts/figures/02_prior_predictive_checks_gram_ranef.pdf\n")

# ============================================================================
# 4. Interpretation summary
# ============================================================================
cat("\n=== PRIOR VALIDATION SUMMARY ===\n")
cat("\nGood signs (prior is reasonable):\n")
cat("✓ Prior generates ~50% baseline accuracy (Intercept ≈ 0)\n")
cat("✓ Condition effect varies but is typically moderate\n")
cat("✓ Between-subject accuracy ranges 30-70% or similar\n")
cat("✓ No impossible values (all between 0 and 1)\n")

cat("\nIf you see problems, adjust priors and rerun.\n")
cat("Example issues:\n")
cat("✗ Mean accuracy >> 90%: intercept prior too high\n")
cat("✗ All subjects 50% ± 1%: intercept SD too small\n")
cat("✗ Very weak prior predictions: slopes prior too small\n")

cat("\n=== Script complete! ===\n")
cat("Generated PDFs in materials/scripts/figures/:\n")
cat("  - 02_prior_predictive_checks_gram_visuals.pdf\n")
cat("  - 02_prior_predictive_checks_gram_ranef.pdf\n")
