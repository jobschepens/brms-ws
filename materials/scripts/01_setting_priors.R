# Check default priors in brms for typical psycholinguistics models
# Script to verify what get_prior() actually returns
# Test if default priors change based on data values

library(brms)

# Create simple example datasets
set.seed(123)

# Example 1: Reaction Time data (log-transformed) - TYPICAL VALUES
rt_data_typical <- data.frame(
  subject = factor(rep(1:20, each = 10)),
  item = factor(rep(1:10, times = 20)),
  condition = factor(rep(c("A", "B"), each = 5, times = 20)),
  log_rt = rnorm(200, mean = 6, sd = 0.5)  # log(400ms)
)

# Example 1b: RT data with VERY DIFFERENT VALUES
rt_data_extreme <- data.frame(
  subject = factor(rep(1:20, each = 10)),
  item = factor(rep(1:10, times = 20)),
  condition = factor(rep(c("A", "B"), each = 5, times = 20)),
  log_rt = rnorm(200, mean = 10, sd = 2)  # log(22000ms) - unrealistic!
)

# Example 2: Grammaticality Judgment data (binary) - TYPICAL
gram_data_typical <- data.frame(
  subject = factor(rep(1:20, each = 10)),
  item = factor(rep(1:10, times = 20)),
  condition = factor(rep(c("A", "B"), each = 5, times = 20)),
  correct = rbinom(200, 1, 0.7)  # 70% accuracy
)

# Example 2b: Grammaticality Judgment - HIGH ACCURACY
gram_data_high <- data.frame(
  subject = factor(rep(1:20, each = 10)),
  item = factor(rep(1:10, times = 20)),
  condition = factor(rep(c("A", "B"), each = 5, times = 20)),
  correct = rbinom(200, 1, 0.95)  # 95% accuracy
)

# Example 2c: Grammaticality Judgment - LOW ACCURACY
gram_data_low <- data.frame(
  subject = factor(rep(1:20, each = 10)),
  item = factor(rep(1:10, times = 20)),
  condition = factor(rep(c("A", "B"), each = 5, times = 20)),
  correct = rbinom(200, 1, 0.3)  # 30% accuracy
)

cat("\n=== DEFAULT PRIORS FOR GAUSSIAN (RT) MODEL - TYPICAL VALUES ===\n")
cat("Formula: log_rt ~ condition + (1 + condition | subject) + (1 | item)\n")
cat("Data: mean(log_rt) =", round(mean(rt_data_typical$log_rt), 2), 
    "→ exp(6) ≈ 403ms\n\n")
rt_priors_typical <- get_prior(log_rt ~ condition + (1 + condition | subject) + (1 | item),
                                data = rt_data_typical, 
                                family = gaussian())
print(rt_priors_typical)

cat("\n\n=== DEFAULT PRIORS FOR GAUSSIAN (RT) MODEL - EXTREME VALUES ===\n")
cat("Formula: log_rt ~ condition + (1 + condition | subject) + (1 | item)\n")
cat("Data: mean(log_rt) =", round(mean(rt_data_extreme$log_rt), 2), 
    "→ exp(10) ≈ 22026ms\n\n")
rt_priors_extreme <- get_prior(log_rt ~ condition + (1 + condition | subject) + (1 | item),
                                data = rt_data_extreme, 
                                family = gaussian())
print(rt_priors_extreme)

cat("\n\n=== COMPARISON: Do Intercept priors change with data? ===\n")
typical_intercept <- rt_priors_typical[rt_priors_typical$class == "Intercept", "prior"]
extreme_intercept <- rt_priors_extreme[rt_priors_extreme$class == "Intercept", "prior"]
cat("Typical data Intercept prior:", typical_intercept, "\n")
cat("Extreme data Intercept prior:", extreme_intercept, "\n")
if (typical_intercept == extreme_intercept) {
  cat("→ Priors are IDENTICAL - brms uses same default regardless of data!\n")
} else {
  cat("→ Priors DIFFER - brms adapts to data scale!\n")
}

cat("\n\n=== DEFAULT PRIORS FOR BERNOULLI (GRAMMATICALITY) MODEL - TYPICAL ===\n")
cat("Formula: correct ~ condition + (1 + condition | subject) + (1 | item)\n")
cat("Data: mean(correct) =", round(mean(gram_data_typical$correct), 2), 
    "→", round(mean(gram_data_typical$correct)*100, 1), "% accuracy\n\n")
gram_priors_typical <- get_prior(correct ~ condition + (1 + condition | subject) + (1 | item),
                                 data = gram_data_typical, 
                                 family = bernoulli())
print(gram_priors_typical)

cat("\n\n=== DEFAULT PRIORS FOR BERNOULLI (GRAMMATICALITY) MODEL - HIGH ===\n")
cat("Formula: correct ~ condition + (1 + condition | subject) + (1 | item)\n")
cat("Data: mean(correct) =", round(mean(gram_data_high$correct), 2), 
    "→", round(mean(gram_data_high$correct)*100, 1), "% accuracy\n\n")
gram_priors_high <- get_prior(correct ~ condition + (1 + condition | subject) + (1 | item),
                               data = gram_data_high, 
                               family = bernoulli())
print(gram_priors_high)

cat("\n\n=== DEFAULT PRIORS FOR BERNOULLI (GRAMMATICALITY) MODEL - LOW ===\n")
cat("Formula: correct ~ condition + (1 + condition | subject) + (1 | item)\n")
cat("Data: mean(correct) =", round(mean(gram_data_low$correct), 2), 
    "→", round(mean(gram_data_low$correct)*100, 1), "% accuracy\n\n")
gram_priors_low <- get_prior(correct ~ condition + (1 + condition | subject) + (1 | item),
                              data = gram_data_low, 
                              family = bernoulli())
print(gram_priors_low)

cat("\n\n=== COMPARISON: Do Intercept priors change for binary data? ===\n")
typical_gram_intercept <- gram_priors_typical[gram_priors_typical$class == "Intercept", "prior"]
high_gram_intercept <- gram_priors_high[gram_priors_high$class == "Intercept", "prior"]
low_gram_intercept <- gram_priors_low[gram_priors_low$class == "Intercept", "prior"]
cat("70% accuracy Intercept prior:", typical_gram_intercept, "\n")
cat("95% accuracy Intercept prior:", high_gram_intercept, "\n")
cat("30% accuracy Intercept prior:", low_gram_intercept, "\n")
if (typical_gram_intercept == high_gram_intercept && high_gram_intercept == low_gram_intercept) {
  cat("→ Priors are IDENTICAL - brms uses student_t(3, 0, 2.5) for all binary data\n")
  cat("→ This makes sense: logistic regression intercept is on log-odds scale\n")
  cat("→ 0 on log-odds = 50% probability, regardless of your data\n")
} else {
  cat("→ Priors DIFFER - brms might adapt to observed proportions!\n")
}

cat("\n\n=== OVERALL SUMMARY ===\n")
cat("1. Gaussian model has 'sigma' (residual SD), Bernoulli does not\n")
cat("2. Both have 'Intercept', 'b' (slopes), 'sd' (random effects), 'cor' (correlations)\n")
cat("3. Intercept gets student_t prior centered at mean(y) for Gaussian\n")
cat("4. Slopes (b) have flat priors - '(flat)' means uniform on unbounded range\n")
cat("5. Default cor prior is lkj(1) - uniform over correlation matrices\n")
cat("6. student_t(3, 0, 2.5) is used for sigma and sd - weakly informative\n")
cat("\n*** KEY FINDING: Check if Intercept prior location adapts to your data! ***\n")
