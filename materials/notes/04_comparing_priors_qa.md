# 5. Comparing Priors & Q&A (10-15 min)

How sensitive are your results to prior choice? Validate robustness by fitting models with different plausible priors.

## Why Compare Priors?

Prior sensitivity analysis shows whether your conclusions depend heavily on specific prior choices or whether they're robust across reasonable alternatives. This is especially important for:
- Publication: reviewers will ask "how robust is your result?"
- Model criticism: if results change dramatically with different priors, something's wrong
- Theory building: consistent results across priors = stronger evidence

## Reaction Time Example

### Fit with different priors

```r
# Original (domain-informed) priors
rt_priors_domain <- c(
  prior(normal(6, 1.5), class = Intercept),
  prior(normal(0, 0.5), class = b),
  prior(exponential(1), class = sigma),
  prior(exponential(1), class = sd)
)

fit_rt_domain <- brm(log_rt ~ condition + (1 + condition | subject) + (1 | item),
                     data = rt_data, family = gaussian(), 
                     prior = rt_priors_domain, seed = 1234)

# Wider priors (less informative)
rt_priors_wide <- c(
  prior(normal(6, 3), class = Intercept),     # More uncertainty
  prior(normal(0, 1), class = b),             # Slopes could be larger
  prior(exponential(0.5), class = sigma),     # Less constraint on noise
  prior(exponential(0.5), class = sd)         # Less constraint on RE
)

fit_rt_wide <- brm(log_rt ~ condition + (1 + condition | subject) + (1 | item),
                   data = rt_data, family = gaussian(), 
                   prior = rt_priors_wide, seed = 1234)

# Narrower priors (more informative)
rt_priors_narrow <- c(
  prior(normal(6, 0.8), class = Intercept),  # Tight around 400ms
  prior(normal(0, 0.3), class = b),          # Small effects expected
  prior(exponential(2), class = sigma),      # Low noise expected
  prior(exponential(2), class = sd)
)

fit_rt_narrow <- brm(log_rt ~ condition + (1 + condition | subject) + (1 | item),
                     data = rt_data, family = gaussian(), 
                     prior = rt_priors_narrow, seed = 1234)
```

### Compare posterior summaries

```r
# Extract results
posterior_summary(fit_rt_domain)
posterior_summary(fit_rt_wide)
posterior_summary(fit_rt_narrow)

# More compact comparison
coef_domain <- as_draws_df(fit_rt_domain)
coef_wide <- as_draws_df(fit_rt_wide)
coef_narrow <- as_draws_df(fit_rt_narrow)

# Compare Intercept posteriors
cat("Intercept posteriors:\n")
cat("Domain:  ", quantile(coef_domain$b_Intercept, c(0.025, 0.5, 0.975)), "\n")
cat("Wide:    ", quantile(coef_wide$b_Intercept, c(0.025, 0.5, 0.975)), "\n")
cat("Narrow:  ", quantile(coef_narrow$b_Intercept, c(0.025, 0.5, 0.975)), "\n")

# Compare effect size posteriors
cat("\nCondition effect posteriors:\n")
cat("Domain:  ", quantile(coef_domain$b_conditionB, c(0.025, 0.5, 0.975)), "\n")
cat("Wide:    ", quantile(coef_wide$b_conditionB, c(0.025, 0.5, 0.975)), "\n")
cat("Narrow:  ", quantile(coef_narrow$b_conditionB, c(0.025, 0.5, 0.975)), "\n")
```

### Visualize comparison

```r
# Create a comparison plot
library(tidyverse)

# Extract draws from all three models
draws_all <- bind_rows(
  as_draws_df(fit_rt_domain) %>% mutate(prior_type = "Domain"),
  as_draws_df(fit_rt_wide) %>% mutate(prior_type = "Wide"),
  as_draws_df(fit_rt_narrow) %>% mutate(prior_type = "Narrow")
)

# Plot effect size distributions
draws_all %>%
  ggplot(aes(x = b_conditionB, fill = prior_type)) +
  geom_density(alpha = 0.4) +
  labs(title = "Posterior effect size under different priors",
       x = "Effect of condition B (log scale)")

# Plot in data units
draws_all %>%
  mutate(effect_ms = exp(6 + b_conditionB) - exp(6)) %>%
  ggplot(aes(x = effect_ms, fill = prior_type)) +
  geom_density(alpha = 0.4) +
  labs(title = "Posterior effect size (milliseconds)",
       x = "RT difference for condition B")
```

## Grammaticality Judgment Example

### Compare across prior specifications

```r
# Domain-informed
gram_priors_domain <- c(
  prior(normal(0, 1.5), class = Intercept),
  prior(normal(0, 1), class = b),
  prior(exponential(1), class = sd),
  prior(lkj(2), class = cor)
)

fit_gram_domain <- brm(correct ~ condition + (1 + condition | subject) + (1 | item),
                       data = gram_data, family = bernoulli(link = "logit"),
                       prior = gram_priors_domain, seed = 1234)

# Wide priors
gram_priors_wide <- c(
  prior(normal(0, 3), class = Intercept),
  prior(normal(0, 2), class = b),
  prior(exponential(0.5), class = sd),
  prior(lkj(1), class = cor)
)

fit_gram_wide <- brm(correct ~ condition + (1 + condition | subject) + (1 | item),
                     data = gram_data, family = bernoulli(link = "logit"),
                     prior = gram_priors_wide, seed = 1234)
```

### Compare predicted probabilities

```r
# Predictions for typical scenario
new_data <- expand.grid(
  condition = c("A", "B"),
  subject = NA,
  item = NA
)

# Get predicted probabilities
pred_domain <- posterior_epred(fit_gram_domain, newdata = new_data, re_formula = NA)
pred_wide <- posterior_epred(fit_gram_wide, newdata = new_data, re_formula = NA)

# Compare
cat("Condition A accuracy:\n")
cat("Domain prior: ", quantile(pred_domain[, 1], c(0.025, 0.5, 0.975)), "\n")
cat("Wide prior:   ", quantile(pred_wide[, 1], c(0.025, 0.5, 0.975)), "\n")

cat("\nCondition B accuracy:\n")
cat("Domain prior: ", quantile(pred_domain[, 2], c(0.025, 0.5, 0.975)), "\n")
cat("Wide prior:   ", quantile(pred_wide[, 2], c(0.025, 0.5, 0.975)), "\n")
```

## Interpretation Guide

### What to look for

**Robust results:**
- Posteriors roughly overlap across prior specifications
- Conclusions (e.g., "effect exists" vs. "effect absent") consistent
- Differences are small relative to uncertainty

**Fragile results:**
- Posteriors diverge substantially
- Conclusions flip depending on prior
- Suggests your data isn't informative enough or model is misspecified

### Decision rules

| Scenario | Interpretation | Action |
|----------|-----------------|--------|
| All three priors → same conclusion | **Robust** | Report all three, state main result |
| Domain prior only → strong effect | **Sensitive** | Acknowledge sensitivity, report all |
| Results change with narrower prior | **Data weak** | Collect more data or simplify model |
| Results consistent, posteriors overlap | **Robust** | Justified in using domain prior |

## Q&A: Common Questions

### "How do I compare models with LOO cross-validation?"

**Answer**: Use `loo_compare()` to see which model predicts better:

```r
# Fit models with custom priors
fit_rt_simple <- brm(log_rt ~ condition + (1 | subject) + (1 | item),
                     data = rt_data, family = gaussian(),
                     prior = rt_priors_domain)

fit_rt_complex <- brm(log_rt ~ condition + (1 + condition | subject) + (1 | item),
                      data = rt_data, family = gaussian(),
                      prior = rt_priors_domain)

# Add LOO criterion
fit_rt_simple <- add_criterion(fit_rt_simple, "loo")
fit_rt_complex <- add_criterion(fit_rt_complex, "loo")

# Compare
loo_compare(fit_rt_simple, fit_rt_complex)
```

**Output interpretation:**
```
##                  elpd_diff se_diff
## fit_rt_complex    0.0       0.0
## fit_rt_simple   -12.4       5.2
```

### Rule of thumb for model comparison

**Interpreting `elpd_diff` (expected log pointwise predictive density difference):**

| elpd_diff | se_diff ratio* | Interpretation | Action |
|-----------|----------------|----------------|--------|
| \|diff\| < 4 | < 4 | Equivalent models | Pick simpler one |
| 4-10 | 4-10 | Moderate difference | Prefer larger elpd |
| > 10 | > 10 | Clear winner | Prefer larger elpd |

*Ratio = \|elpd_diff\| / se_diff (how many standard errors apart?)

**Your example:**
```
## elpd_diff se_diff
## model1_loo 0.0 0.0
## model2_loo -0.2 0.8
```
- Ratio: 0.2 / 0.8 = **0.25 standard errors**
- **Verdict**: Models are indistinguishable
- **Action**: Pick the simpler model

### Calculating and interpreting the ratio

```r
# After loo_compare()
loo_comp <- loo_compare(fit_model1, fit_model2)

# Extract difference and SE
elpd_diff <- loo_comp[2, 1]  # Gets value for second model
se_diff <- loo_comp[2, 2]

# Calculate ratio
ratio <- abs(elpd_diff) / se_diff

if (ratio < 4) {
  cat("Models are equivalent - choose the simpler one\n")
} else if (ratio < 10) {
  cat("Moderate difference - prefer the better fit\n")
} else {
  cat("Clear winner - strong preference for better model\n")
}
```

### What elpd actually means

- **elpd** = "Expected Log Pointwise Predictive Density"
- **Higher is better** (like R² in frequentist stats)
- **Difference matters**: which model predicts new data better?
- **Not about fit to current data**: about generalization

### Common scenarios

**Scenario 1: Adding random slopes**
```
Simple (intercept only):   elpd = 100.0
Complex (slope too):       elpd = 105.2  (elpd_diff = 5.2, se = 2.1)
Ratio = 5.2 / 2.1 = 2.5 standard errors
→ Weak evidence for random slopes, close call
```

**Scenario 2: Unnecessary interaction**
```
Main effects only:         elpd = 200.0
With interaction:          elpd = 199.8  (elpd_diff = -0.2, se = 1.5)
Ratio = 0.2 / 1.5 = 0.13 standard errors
→ Interaction doesn't help, use simpler model
```

**Scenario 3: Critical difference**
```
Bad model:                 elpd = 50.0
Good model:                elpd = 75.0   (elpd_diff = 25.0, se = 3.0)
Ratio = 25.0 / 3.0 = 8.3 standard errors
→ Clear winner, use good model
```

### Why use LOO instead of just comparing priors?

**Prior comparison** (what we did earlier):
- Shows if posteriors are sensitive to prior choice
- Good for: reporting robustness

**LOO comparison** (new approach):
- Shows which model predicts better
- Good for: feature selection, model building
- Different question: "Which priors produce better predictions?"

You can do both:
1. First: Compare different priors within same model structure
2. Then: Use LOO to compare different model structures with best priors

---

## Q&A: Common Questions

### "Isn't using domain priors just imposing my beliefs?"

**Answer**: Yes, exactly. The question is whether your beliefs are *reasonable*. Prior specification is:
- Data: "Everyone agrees this is fact"
- Reasonable prior: "Domain experts expect this range"
- Unreasonable prior: "I want results to look like this"

If experts in linguistics expect RTs of 200-1000ms, that's reasonable. If your prior forces results to match your hypothesis, that's not.

### "How different should my alternative priors be?"

**Answer**: Use the range of *reasonable* specifications:
- **Narrow**: informed by strong prior knowledge
- **Domain**: your best guess (typically used for main analysis)
- **Wide**: vague but still plausible (not completely flat)

Don't use:
- Priors that violate domain knowledge (e.g., negative RTs)
- Priors that are technically possible but implausible

### "What if results change with different priors?"

**Options**:
1. **Collect more data** - let data dominate the prior
2. **Refine your prior** - discuss with domain experts
3. **Simplify the model** - maybe you're overfitting
4. **Report the sensitivity** - honest science: "Results depend on prior choice"

### "Should I always compare priors?"

**Recommended**:
- ✅ Always: For main effects you're claiming are "real"
- ✅ Always: For publication
- ⏱️ Optional: For exploratory analyses
- ✅ Always: If anyone questions your priors

## Summary Checklist

- [ ] Fit model with your domain-informed prior
- [ ] Fit same model with wider/narrower alternatives
- [ ] Compare posterior summaries (quantiles, HDI)
- [ ] Check if conclusions change
- [ ] Visualize posterior distributions
- [ ] Document prior sensitivity findings
- [ ] Report all three (or more) prior specifications
