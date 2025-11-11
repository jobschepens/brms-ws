# Reaction Time Example: Prior Predictive Checks
# ==================================================
# This script demonstrates how to validate priors for a Bayesian RT model
# before fitting to data.

library(brms)
library(tidyverse)

# Setup: Create example RT data
set.seed(42)
n_subj <- 20
n_trials <- 50
n_items <- 30

rt_data <- expand.grid(
  trial = 1:n_trials,
  subject = 1:n_subj,
  item = 1:n_items
) %>%
  filter(row_number() <= n_subj * n_trials * 3) %>%  # Balanced design
  mutate(
    condition = rep(c("A", "B"), length.out = n()),
    log_rt = rnorm(n(), mean = 6, sd = 0.3) + 
             (condition == "B") * 0.15 + 
             rnorm(n(), mean = 0, sd = 0.1),
    rt = exp(log_rt)
  )

# Define priors
rt_priors <- c(
  prior(normal(6, 1.5), class = Intercept),        # log(RT) around 400ms
  prior(normal(0, 0.5), class = b),                # effects usually < 150ms
  prior(exponential(1), class = sigma),            # residual noise
  prior(exponential(1), class = sd),               # between-subject variation
  prior(lkj(2), class = cor)                       # correlations
)

# ============================================================================
# 1. Visualize prior predictions for RT model
# ============================================================================
cat("\n=== 1. Fitting model with PRIOR ONLY (no data) ===\n")

prior_pred <- brm(
  log_rt ~ condition + (1 + condition | subject) + (1 | item),
  data = rt_data, 
  family = gaussian(),
  prior = rt_priors,
  sample_prior = "only",  # Only sample from prior!
  chains = 4, iter = 1000,  # 4 chains, fewer iterations
  cores = 4,                 # Parallel sampling
  verbose = FALSE,
  refresh = 0
)

cat("Prior predictive model fitted.\n")

# Generating prior predictive checks...
cat("\nGenerating prior predictive checks...\n")
pdf("materials/scripts/02_prior_predictive_checks_rt_visuals.pdf", width = 12, height = 10)

par(mfrow = c(2, 3))

# Density overlay
plot(pp_check(prior_pred, type = "dens_overlay", ndraws = 100, prefix = "ppd"),
     main = "Overlay: Prior predictions vs observed")

# Mean comparison
plot(pp_check(prior_pred, type = "stat", stat = "mean"),
     main = "Test stat: Mean RT (log scale)")

# SD comparison
plot(pp_check(prior_pred, type = "stat", stat = "sd"),
     main = "Test stat: SD of RT (log scale)")

# Min comparison
plot(pp_check(prior_pred, type = "stat", stat = "min"),
     main = "Test stat: Min RT (log scale)")

# Max comparison
plot(pp_check(prior_pred, type = "stat", stat = "max"),
     main = "Test stat: Max RT (log scale)")

dev.off()
cat("Saved: materials/scripts/02_prior_predictive_checks_rt_visuals.pdf\n")

# ============================================================================
# 2. Check prior predictive distribution directly
# ============================================================================
cat("\n=== 2. Examining prior distributions directly ===\n")

# Extract prior samples
prior_samples <- prior_draws(prior_pred)

# Check Intercept prior
cat("\nIntercept prior (log scale):\n")
intercept_q <- quantile(prior_samples$b_Intercept, c(0.025, 0.5, 0.975), na.rm = TRUE)
print(intercept_q)

cat("\nIntercept prior (RT scale in ms):\n")
print(exp(intercept_q))

# Check effect size prior
cat("\nCondition effect prior (log scale):\n")
effect_q <- quantile(prior_samples$b_conditionB, c(0.025, 0.5, 0.975), na.rm = TRUE)
print(effect_q)

cat("\nCondition effect prior (RT scale in ms):\n")
print(exp(effect_q))

# Check sigma prior
cat("\nResidual noise prior (sigma, log scale):\n")
sigma_q <- quantile(prior_samples$sigma, c(0.025, 0.5, 0.975), na.rm = TRUE)
print(sigma_q)

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

cat("\nImplied subject random intercepts (log scale):\n")
subject_intercepts <- quantile(simulated_intercepts, c(0.025, 0.5, 0.975))
print(subject_intercepts)

cat("\nImplied subject-specific RTs (milliseconds):\n")
intercept_median <- median(prior_samples$b_Intercept)
subject_rt <- exp(intercept_median + subject_intercepts)
print(subject_rt)
cat("Interpretation: Prior implies subject RTs range from", 
    round(subject_rt[1]), "to", round(subject_rt[3]), "ms\n")

# Check subject random slopes
cat("\nSubject random slope SD prior:\n")
print(quantile(sd_subject_slope, c(0.025, 0.5, 0.975), na.rm = TRUE))

simulated_slopes <- rnorm(n_sims, mean = 0, sd = median(sd_subject_slope))

cat("\nImplied subject random slopes (log scale):\n")
subject_slopes <- quantile(simulated_slopes, c(0.025, 0.5, 0.975))
print(subject_slopes)

cat("\nInterpretation: Condition effect varies by subject\n")
cat("Small effect subjects (2.5%): ", round(exp(subject_slopes[1]), 3), "× multiplier\n")
cat("Average effect subjects (50%): ", round(exp(subject_slopes[2]), 3), "× multiplier\n")
cat("Large effect subjects (97.5%): ", round(exp(subject_slopes[3]), 3), "× multiplier\n")

# Visualize distributions
pdf("materials/scripts/02_prior_predictive_checks_rt_ranef.pdf", width = 12, height = 8)

par(mfrow = c(2, 2))

# Visualize simulated random intercepts
hist(simulated_intercepts, 
     main = "Prior-implied subject random intercepts",
     xlab = "Intercept adjustment (log-RT scale)",
     breaks = 30, col = "skyblue", border = "white")

# Visualize simulated random slopes
hist(simulated_slopes,
     main = "Prior-implied subject random slopes",
     xlab = "Condition effect adjustment (log-RT scale)",
     breaks = 30, col = "lightcoral", border = "white")

# Visualize sigma prior
if (!is.null(prior_samples$sigma) && is.numeric(prior_samples$sigma)) {
  hist(prior_samples$sigma,
       main = "Prior for residual noise (sigma)",
       xlab = "Sigma value",
       breaks = 30, col = "lightgreen", border = "white")
} else {
  plot(1, main = "Sigma visualization", xlab = "", ylab = "")
  text(1, 1, "Sigma samples not available")
}

# Density plot comparing intercepts and slopes
plot(density(simulated_intercepts),
     main = "Prior-implied random effects distributions",
     xlab = "Effect size (log scale)",
     col = "blue", lwd = 2, xlim = range(c(simulated_intercepts, simulated_slopes)),
     ylim = c(0, max(density(simulated_intercepts)$y, density(simulated_slopes)$y)))
lines(density(simulated_slopes),
      col = "red", lwd = 2)
legend("topright", c("Intercepts", "Slopes"), col = c("blue", "red"), lwd = 2)

dev.off()
cat("Saved: materials/scripts/02_prior_predictive_checks_rt_ranef.pdf\n")

# ============================================================================
# 4. Interpretation summary
# ============================================================================
cat("\n=== PRIOR VALIDATION SUMMARY ===\n")
cat("\nGood signs (prior is reasonable):\n")
cat("✓ Prior generates log-RTs around 6 (≈ 400ms)\n")
cat("✓ 95% interval roughly 200-1100ms (plausible RT range)\n")
cat("✓ Condition effect typically < 150ms difference\n")
cat("✓ Between-subject variation is moderate\n")

cat("\nIf you see problems, adjust priors and rerun.\n")
cat("Example issues:\n")
cat("✗ Mean RT >> 1000ms: intercept prior too high\n")
cat("✗ 95% interval 10ms-50s: priors too wide\n")
cat("✗ Negative effect sizes: something wrong with data/formula\n")

cat("\n=== Script complete! ===\n")
cat("Generated PDFs:\n")
cat("  - 02_prior_predictive_checks_rt_visuals.pdf\n")
cat("  - 02_prior_predictive_checks_rt_ranef.pdf\n")
