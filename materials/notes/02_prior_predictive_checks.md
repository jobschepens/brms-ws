# 2. Prior Predictive Checks (15 min)

Check if priors produce reasonable predictions BEFORE seeing the data.

## Why Prior Predictive Checks Matter

Before fitting your model to actual data, validate that your priors generate sensible predictions. This is crucial because:
- A prior that's too restrictive can prevent the model from learning from data
- A prior that's too permissive might not regularize your estimates
- It's much easier to revise priors before fitting than after

## Reaction Time Example

### Visualize prior predictions for RT model

```r
# Fit model with priors only (no data)
prior_pred <- brm(log_rt ~ condition + (1 + condition | subject) + (1 | item),
                  data = rt_data, family = gaussian(),
                  prior = rt_priors,
                  sample_prior = "only")  # Only sample from prior!

# Visual checks
pp_check(prior_pred, type = "dens_overlay", ndraws = 100, prefix = "ppd")  # Overlay: observed vs simulated densities
pp_check(prior_pred, type = "stat", stat = "mean")  # Test statistic: compare means
pp_check(prior_pred, type = "stat", stat = "sd")  # Test statistic: compare standard deviations
```

### Check prior predictive distribution directly

```r
# Extract prior samples (use as_draws_df for sample_prior = "only")
prior_samples <- as_draws_df(prior_pred)

# Check Intercept prior
hist(prior_samples$b_Intercept, main = "Prior for Intercept")
quantile(prior_samples$b_Intercept, c(0.025, 0.5, 0.975))

# Check effect size prior
hist(prior_samples$b_conditionB, main = "Prior for condition effect")

# Convert to RT scale to interpret
exp(quantile(prior_samples$b_Intercept, c(0.025, 0.5, 0.975)))  # In milliseconds
```

### Check random effect distributions

```r
# Extract hyperprior SDs and simulate random effects
prior_samples <- as_draws_df(prior_pred)

# Extract subject random intercept SD
sd_subject_intercept <- prior_samples$sd_subject__Intercept

# Simulate random intercepts using the hyperprior SD
n_sims <- 1000
simulated_intercepts <- rnorm(n_sims, mean = 0, sd = median(sd_subject_intercept))

hist(simulated_intercepts, 
     main = "Implied subject random intercepts",
     xlab = "Intercept adjustment (log-RT scale)")
quantile(simulated_intercepts, c(0.025, 0.5, 0.975))

# Convert to RT scale to check realism
# Example: if quantiles are [-0.1, 0, 0.1] in log scale
# then in RT scale: exp(6 + c(-0.1, 0, 0.1)) = [375ms, 403ms, 435ms]
# → realistic 25-60ms variation across subjects ✓
exp(6 + quantile(simulated_intercepts, c(0.025, 0.5, 0.975)))

# For random slopes: check effect size variation across subjects
sd_subject_slope <- prior_samples$sd_subject__conditionB
simulated_slopes <- rnorm(n_sims, mean = 0, sd = median(sd_subject_slope))

hist(simulated_slopes,
     main = "Implied subject random slopes",
     xlab = "Condition effect adjustment")
quantile(simulated_slopes, c(0.025, 0.5, 0.975))
```

## Grammaticality Judgment Example

### Prior predictive checks for binary data

```r
# Sample from prior only
prior_pred_gram <- brm(correct ~ condition + (1 + condition | subject) + (1 | item),
                       data = gram_data, family = bernoulli(),
                       prior = gram_priors,
                       sample_prior = "only")

# Visual checks - for binary data, use different plot types
pp_check(prior_pred_gram, type = "stat", stat = "mean")  # Test statistic: compare proportion of 1's (mean = % correct)
pp_check(prior_pred_gram, type = "error_binned")  # Error plot: prediction accuracy separated by actual outcome (0 vs 1)

# Check if prior predictions are reasonable
prior_pred_samples <- posterior_predict(prior_pred_gram, ndraws = 1000)
mean(prior_pred_samples)  # Should be close to 0.5 if prior is centered at 0
```

### Check random effect distributions

```r
# Extract hyperprior SDs and simulate random effects
prior_samples <- as_draws_df(prior_pred_gram)

# Extract subject random intercept SD
sd_subject_intercept <- prior_samples$sd_subject__Intercept

# Simulate random intercepts using the hyperprior SD
n_sims <- 1000
simulated_intercepts <- rnorm(n_sims, mean = 0, sd = median(sd_subject_intercept))

hist(simulated_intercepts, 
     main = "Implied subject random intercepts",
     xlab = "Intercept adjustment (log-odds scale)")
quantile(simulated_intercepts, c(0.025, 0.5, 0.975))

# Convert to probability scale to check realism
# Example: if quantiles are [-0.5, 0, 0.5] in log-odds
# then in probability scale: plogis(0 + c(-0.5, 0, 0.5)) = [0.38, 0.5, 0.62]
# → realistic 38-62% variation across subjects ✓
plogis(0 + quantile(simulated_intercepts, c(0.025, 0.5, 0.975)))

# For random slopes: check effect size variation across subjects
sd_subject_slope <- prior_samples$sd_subject__conditionB
simulated_slopes <- rnorm(n_sims, mean = 0, sd = median(sd_subject_slope))

hist(simulated_slopes,
     main = "Implied subject random slopes",
     xlab = "Condition effect adjustment (log-odds)")
quantile(simulated_slopes, c(0.025, 0.5, 0.975))
```

## Interpretation Guide

### What to look for

**Good prior predictive checks:**
- Data generated from the prior looks plausible
- Mean/SD of prior predictions aligns with domain knowledge
- No obviously impossible values (RTs of 0ms, accuracies > 100%)

**Problems to fix:**
- Prior generates unrealistic values (RTs of 1000ms every trial)
- Prior is too concentrated (won't let data inform the model)
- Prior allows impossible values (negative RTs, probabilities > 1)

### Example: Interpreting RT prior predictions

If your prior generates:
- Mean RT ≈ 600ms: reasonable baseline
- 95% interval: 200ms - 2000ms: good, covers typical range
- Some trials < 50ms or > 5000ms: probably OK if rare

If instead:
- Mean RT ≈ 10,000ms: too high, fix the prior location
- 95% interval: 10ms - 50s: way too wide, reduce prior SD
- Negative RTs: something went wrong with your transformation

## Tips for Effective Prior Checking

1. **Always check both Intercept and slopes**
   - Visual inspection of prior samples
   - Quantiles to understand spread
   - Convert to interpretable units (ms, %, etc.)

2. **Think about extremes**
   - What's the most extreme plausible value?
   - How often does the prior generate it?

3. **Compare across groups**
   - For mixed effects, check random effect distributions
   - Ensure between-subject variation is realistic
   - See code examples in RT and Grammaticality Judgment sections above

4. **Iterate as needed**
   - First pass: broad checks
   - Second pass: refine if needed
   - Document your reasoning
