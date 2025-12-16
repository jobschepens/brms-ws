# 4. Comparing Priors: influence on coefficients and effect sizes (10-15 min)

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

# Narrower priors (more informative) / regularizing
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
- ✅ Always: If anyone questions your priors

