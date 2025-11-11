# 4. Posterior Predictive Checks (15 min)

After fitting your model, validate that it generates data similar to what you observed.

## Why Posterior Predictive Checks Matter

Posterior predictive checks answer: "If I were to generate new data from my fitted model, would it look like my actual data?" This validates that your model has captured the essential structure of your data.

## Reaction Time Example

### Basic posterior predictive checks

```r
# Default: density overlay of observed vs. simulated data
pp_check(fit_rt, ndraws = 100)

# Check specific statistics
pp_check(fit_rt, type = "stat", stat = "mean")  # Did we get the mean right?
pp_check(fit_rt, type = "stat", stat = "sd")    # Did we get the spread right?
pp_check(fit_rt, type = "stat", stat = "min")   # Extreme values?
```

### Interpretation

- **Blue line** (observed data) should be among the dark lines (posterior predictions)
- If blue line is far from the bundle → model missed something important
- Small discrepancies are normal; large ones suggest model misspecification

### Extract and analyze posterior predictions directly

```r
# Draw from posterior predictive distribution
post_pred <- posterior_predict(fit_rt, ndraws = 1000)
dim(post_pred)  # 1000 draws × n observations

# Compare observed vs. predicted
obs_mean <- mean(rt_data$log_rt)
pred_mean <- apply(post_pred, 1, mean)
hist(pred_mean, main = "Posterior predictive distribution of mean")
abline(v = obs_mean, col = "red", lwd = 2)

# Check 95% posterior predictive interval
post_pred_interval <- apply(post_pred, 2, quantile, c(0.025, 0.975))
# Roughly 95% of observed values should fall within their interval
mean(rt_data$log_rt > post_pred_interval[1,] & 
     rt_data$log_rt < post_pred_interval[2,])
```

## Grammaticality Judgment Example

### Posterior predictive checks for binary data

```r
# Bar plot for binary outcomes
pp_check(fit_gram, type = "bars", ndraws = 500)

# Check observed proportion vs. predicted
pp_check(fit_gram, type = "stat", stat = "mean")  # Proportion of 1's

# Error plot for discrete data
pp_check(fit_gram, type = "error_binned")
```

### Interpreting binary model checks

- **Observed proportion correct** should be near the central tendency of the posterior predictions
- If observed is far from predicted → model isn't capturing the accuracy pattern
- Common issues: forgetting interactions, wrong random effect structure

### Expected value summaries

```r
# Get predicted probabilities (on 0-1 scale)
post_epred <- posterior_epred(fit_gram)
dim(post_epred)  # 4000 draws × n observations (after thinning)

# Posterior probability of correct for first observation
quantile(post_epred[, 1], c(0.025, 0.5, 0.975))
# Example output: 0.68 to 0.74 with median 0.71

# By condition
gram_data$condition <- relevel(gram_data$condition, ref = "A")
new_dat <- expand.grid(condition = unique(gram_data$condition),
                       subject = NA, item = NA)
epred_condition <- posterior_epred(fit_gram, newdata = new_dat, re_formula = NA)
apply(epred_condition, 2, quantile, c(0.025, 0.5, 0.975))
```

## Key Diagnostics to Check

### For both model types

1. **Visual inspection**
   - Observed data overlaps with posterior predictions
   - No systematic patterns in residuals

2. **Specific statistics**
   - Mean: Did you capture the central tendency?
   - SD: Did you capture the spread?
   - Min/Max: Are extreme values reasonable?

3. **By groups**
   - Check predictions separately for each condition
   - Ensure model captures differences between groups

### Common problems and solutions

| Problem | Diagnosis | Solution |
|---------|-----------|----------|
| Model predictions too narrow | SD of posterior predictions < SD of data | Relax priors, check formula |
| Model predictions too wide | SD of posterior predictions >> SD of data | Tighten priors, add more structure |
| Misses condition effects | Mean differs dramatically by condition | Add condition × random effect interaction |
| Extreme value mismatch | Min/max far from observed | Check for outliers, consider robust models |

## Practical Workflow

1. **Fit your model** with custom priors
   ```r
   fit <- brm(formula, data = mydata, family = gaussian(), prior = my_priors)
   ```

2. **Quick visual check**
   ```r
   pp_check(fit, ndraws = 100)
   ```

3. **If problems spotted, check specific statistics**
   ```r
   pp_check(fit, type = "stat", stat = c("mean", "sd"))
   ```

4. **Extract predictions and compare**
   ```r
   post_pred <- posterior_predict(fit)
   # Calculate whatever diagnostic is most important to you
   ```

5. **Iterate if needed**
   - Adjust model formula or priors
   - Refit and recheck
   - Document what you changed and why
