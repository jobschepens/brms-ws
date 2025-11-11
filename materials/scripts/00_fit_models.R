# Pre-fit models for posterior predictive checks
# ==================================================
# This script fits the models needed for the posterior predictive check examples
# and saves them to fits/ directory for quick loading in Quarto documents.

library(brms)
library(tidyverse)

# Set seed for reproducibility
set.seed(42)

# Create fits directory
dir.create("materials/scripts/fits", showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# 1. Fit RT model
# ============================================================================
cat("\n=== Fitting RT Model ===\n")

# Check if already exists
if (file.exists("materials/scripts/fits/fit_rt.rds")) {
  cat("RT model already exists. Skipping.\n")
  cat("Delete materials/scripts/fits/fit_rt.rds to refit.\n")
} else {
  # Create RT data
  n_subj <- 20
  n_trials <- 50
  n_items <- 30
  
  rt_data <- expand.grid(
    trial = 1:n_trials,
    subject = 1:n_subj,
    item = 1:n_items
  ) %>%
    filter(row_number() <= n_subj * n_trials * 3) %>%
    mutate(
      condition = rep(c("A", "B"), length.out = n()),
      log_rt = rnorm(n(), mean = 6, sd = 0.3) + 
               (condition == "B") * 0.15 + 
               rnorm(n(), mean = 0, sd = 0.1),
      rt = exp(log_rt)
    )
  
  # Define priors
  rt_priors <- c(
    prior(normal(6, 1.5), class = Intercept),
    prior(normal(0, 0.5), class = b),
    prior(exponential(1), class = sigma),
    prior(exponential(1), class = sd),
    prior(lkj(2), class = cor)
  )
  
  cat("Fitting RT model (this will take several minutes)...\n")
  cat("Data: n =", nrow(rt_data), "observations\n")
  cat("Formula: log_rt ~ condition + (1 + condition | subject) + (1 | item)\n")
  cat("Family: gaussian()\n\n")
  
  # Check if we have a prior predictive model to reuse compilation
  if (file.exists("materials/scripts/fits/prior_pred_rt.rds")) {
    cat("Found prior predictive model - will update it with data...\n")
    prior_model <- readRDS("materials/scripts/fits/prior_pred_rt.rds")
    
    fit_rt <- update(
      prior_model,
      newdata = rt_data,
      sample_prior = "no",  # Now use data
      chains = 2,
      iter = 1000,
      cores = 2,
      refresh = 100,
      recompile = FALSE  # Reuse compiled Stan code
    )
  } else {
    # Fit from scratch
    fit_rt <- brm(
      log_rt ~ condition + (1 + condition | subject) + (1 | item),
      data = rt_data,
      family = gaussian(),
      prior = rt_priors,
      chains = 2,
      iter = 1000,
      cores = 2,
      backend = "rstan",
      refresh = 100
    )
  }
  
  # Save model
  saveRDS(fit_rt, "materials/scripts/fits/fit_rt.rds")
  cat("\n✓ RT model saved to: materials/scripts/fits/fit_rt.rds\n")
  
  # Quick summary
  cat("\nModel summary:\n")
  print(summary(fit_rt))
}

# ============================================================================
# 2. Fit Grammaticality Judgment model
# ============================================================================
cat("\n=== Fitting Grammaticality Judgment Model ===\n")

# Check if already exists
if (file.exists("materials/scripts/fits/fit_gram.rds")) {
  cat("Grammaticality model already exists. Skipping.\n")
  cat("Delete materials/scripts/fits/fit_gram.rds to refit.\n")
} else {
  # Create grammaticality data
  n_subj <- 25
  n_trials <- 40
  n_items <- 30
  
  gram_data <- expand.grid(
    trial = 1:n_trials,
    subject = 1:n_subj,
    item = 1:n_items
  ) %>%
    filter(row_number() <= n_subj * n_trials * 2) %>%
    mutate(
      condition = rep(c('A', 'B'), length.out = n()),
      p_correct = plogis(0.2 + (condition == 'B') * 0.4),
      correct = rbinom(n(), size = 1, prob = p_correct)
    )
  
  # Define priors
  gram_priors <- c(
    prior(normal(0, 1.5), class = Intercept),
    prior(normal(0, 1), class = b),
    prior(exponential(1), class = sd),
    prior(lkj(2), class = cor)
  )
  
  cat("Fitting grammaticality model (this will take several minutes)...\n")
  cat("Data: n =", nrow(gram_data), "observations\n")
  cat("Formula: correct ~ condition + (1 + condition | subject) + (1 | item)\n")
  cat("Family: bernoulli()\n\n")
  
  # Check if we have a prior predictive model to reuse compilation
  if (file.exists("materials/scripts/fits/prior_pred_gram.rds")) {
    cat("Found prior predictive model - will update it with data...\n")
    prior_model <- readRDS("materials/scripts/fits/prior_pred_gram.rds")
    
    fit_gram <- update(
      prior_model,
      newdata = gram_data,
      sample_prior = "no",  # Now use data
      chains = 2,
      iter = 1000,
      cores = 2,
      refresh = 100,
      recompile = FALSE  # Reuse compiled Stan code
    )
  } else {
    # Fit from scratch
    fit_gram <- brm(
      correct ~ condition + (1 + condition | subject) + (1 | item),
      data = gram_data,
      family = bernoulli(),
      prior = gram_priors,
      chains = 2,
      iter = 1000,
      cores = 2,
      backend = "rstan",
      refresh = 100
    )
  }
  
  # Save model
  saveRDS(fit_gram, "materials/scripts/fits/fit_gram.rds")
  cat("\n✓ Grammaticality model saved to: materials/scripts/fits/fit_gram.rds\n")
  
  # Quick summary
  cat("\nModel summary:\n")
  print(summary(fit_gram))
}

# ============================================================================
# Summary
# ============================================================================
cat("\n=== Model Fitting Complete ===\n")
cat("\nSaved models:\n")
if (file.exists("materials/scripts/fits/fit_rt.rds")) {
  cat("✓ materials/scripts/fits/fit_rt.rds\n")
}
if (file.exists("materials/scripts/fits/fit_gram.rds")) {
  cat("✓ materials/scripts/fits/fit_gram.rds\n")
}

cat("\nYou can now render the Quarto documents:\n")
cat("  quarto render materials/scripts/03_posterior_predictive_checks_rt.qmd\n")
cat("  quarto render materials/scripts/03_posterior_predictive_checks_gram.qmd\n")
cat("\nThe documents will load these pre-fitted models instantly.\n")
