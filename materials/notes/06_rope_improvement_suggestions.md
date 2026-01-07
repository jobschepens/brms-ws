# Potential Improvements for Module 06 (ROPE) Based on Kruschke Chapters 11 & 12

**Note:** This document synthesizes improvements from Kruschke's *Doing Bayesian Data Analysis* (2015) Chapters 11-12 as implemented in Solomon Kurz's brms/tidyverse translation. The focus is on NHST vs. Bayesian approaches, ROPE methodology, and practical decision-making.

---

## 1. Add Motivating Section: Problems with NHST (New Opening)

**Rationale:** Kruschke Chapter 11 provides powerful motivation for Bayesian approaches by exposing deep flaws in NHST. This would strengthen the module's motivation.

**Where to add:** New section after "Why Practical Significance Matters" (around line 65)

### The NHST Problem: Why p-values Are Not Enough

**Key insight from Kruschke Ch 11:** p-values depend on stopping intentions, not just the data!

**Example to add:**

```r
# Scenario: You flip a coin 24 times, get 7 heads
# Question: Is the coin fair (θ = 0.5)?

# The p-value CHANGES depending on your intention:

# Intention 1: Fixed N = 24 flips
# p-value (two-tailed) = 0.064 → FAIL to reject null

# Intention 2: Fixed z = 7 heads (stop when 7th head appears)  
# p-value (two-tailed) = 0.035 → REJECT null

# Intention 3: Fixed duration (Poisson N with λ=24)
# p-value (two-tailed) = 0.048 → REJECT null (barely)

# SAME DATA, DIFFERENT CONCLUSIONS!
```

**The Bayesian Solution:**

```r
# Bayesian posterior does NOT depend on stopping intentions
# With flat prior Beta(1,1):

n <- 24; z <- 7
posterior_alpha <- z + 1  # = 8
posterior_beta <- n - z + 1  # = 18

# 95% HDI for θ:
library(HDInterval)
hdi(qbeta, shape1 = 8, shape2 = 18)
# Result: [0.14, 0.48]

# This HDI is the SAME regardless of:
# - Whether you planned to stop at N=24, z=7, or fixed time
# - Whether you planned to test one coin or multiple coins
# - Whether you decided to test this hypothesis before or after collecting data
```

**Key message:** "The Bayesian interpretation of data does not depend on the covert sampling and testing intentions of the data collector" (Kruschke, p. 314).

**Why this matters for ROPE:** 
- NHST can only reject the null (never accept it)
- p-values don't tell you about practical significance
- ROPE lets you accept the null AND quantify practical importance

---

## 2. Strengthen ROPE Definition with Kruschke's Precision

**Current:** Basic ROPE explanation exists (around line 400)

**Enhancement:** Add Kruschke's formal definition and key properties

### What ROPE Really Is (Formal Definition)

**From Kruschke p. 336:**

> A region of practical equivalence (ROPE) indicates a small range of parameter values that are considered to be **practically equivalent** to the null value for purposes of the particular application.

**Three Decision Outcomes (not just two!):**

```r
# Current module shows:
# 1. HDI outside ROPE → Reject null (effect is meaningful)
# 2. HDI inside ROPE → Accept null (effect is negligible)

# ADD THE THIRD:
# 3. HDI overlaps ROPE → UNDECIDED (insufficient precision)
#    → This is not a failure! It's honest reporting of uncertainty
```

**Visualization to add:**

```r
library(tidyverse)
library(patchwork)

# Three scenarios
scenarios <- tribble(
  ~scenario, ~mean, ~sd, ~conclusion,
  "Decisive (Reject H0)", 0.12, 0.015, "HDI excludes ROPE\n→ Effect is meaningful",
  "Decisive (Accept H0)", 0.02, 0.008, "HDI inside ROPE\n→ Effect negligible", 
  "Undecided", 0.06, 0.025, "HDI overlaps ROPE\n→ Collect more data"
)

plots <- map(1:3, function(i) {
  x <- seq(-0.1, 0.2, length.out = 1000)
  y <- dnorm(x, scenarios$mean[i], scenarios$sd[i])
  
  tibble(x = x, density = y) %>%
    ggplot() +
    # ROPE region
    geom_rect(xmin = -0.05, xmax = 0.05, 
              ymin = -Inf, ymax = Inf,
              fill = "gray80", alpha = 0.5) +
    # Posterior distribution
    geom_line(aes(x, density), linewidth = 1.2, color = "steelblue") +
    geom_area(aes(x, density), fill = "steelblue", alpha = 0.3) +
    # HDI
    geom_segment(
      x = qnorm(0.025, scenarios$mean[i], scenarios$sd[i]),
      xend = qnorm(0.975, scenarios$mean[i], scenarios$sd[i]),
      y = 0, yend = 0,
      linewidth = 3, color = "darkblue"
    ) +
    annotate("text", x = 0, y = max(y) * 0.9, 
             label = scenarios$conclusion[i],
             size = 3.5, fontface = "bold") +
    annotate("text", x = 0, y = max(y) * 0.1,
             label = "ROPE", size = 3) +
    labs(title = scenarios$scenario[i],
         x = "Effect Size (β)", y = "Posterior Density") +
    theme_minimal() +
    theme(axis.text.y = element_blank())
})

wrap_plots(plots, ncol = 1)
```

**Key insight from Kruschke Ch 12:**

> "It is important to be clear that any discrete decision about rejecting or accepting a null value does not exhaustively capture our knowledge about the parameter value. Our knowledge about the parameter value is described by the full posterior distribution." (p. 338)

---

---

## 3. Strengthen ROPE Boundary Justification (Expand Current Section)

**Current:** Module mentions domain knowledge briefly (around line 450)

**Enhancement:** Add Kruschke's detailed guidance on boundary selection

### Four Methods for Justifying ROPE Boundaries

#### Method 1: Previous Research / Meta-Analysis
```r
# Example: Meta-analysis shows typical RT effect = 100ms (≈0.10 log-units)
# Set ROPE at 1/3 of typical: [-0.03, 0.03]
rope_bounds <- c(-0.03, 0.03)
```

#### Method 2: Measurement Precision
```r
# Example: RT measurement error ≈ 20ms
# ROPE should exceed measurement error
# 20ms ≈ 0.02 log-units → Use ROPE = [-0.03, 0.03]
rope_bounds <- c(-0.03, 0.03)
```

#### Method 3: Perceptual/Practical Thresholds
```r
# Example: Readers cannot perceive < 50ms differences
# 50ms ≈ 0.05 log-units → ROPE = [-0.05, 0.05]
rope_bounds <- c(-0.05, 0.05)
```

#### Method 4: Standardized Effect Sizes (Cohen's d)
```r
# Cohen's d = 0.2 considered "small"
# Set ROPE at half of small: d = 0.1
# Convert to your outcome scale
rope_bounds <- c(-0.1, 0.1)  # If working in standardized units
```

**Add Worked Example:**

```r
# Scenario: Grammaticality judgment accuracy
# Research question: Does training improve accuracy?

# Domain knowledge:
# - Ceiling effect: Accuracy typically 85-95%
# - Meaningful improvement: > 5 percentage points
# - Model: Logistic regression (logit scale)

# Convert percentage points to logit scale
library(qlogis)  # For inverse logit

# At baseline accuracy of 90%:
baseline_logit <- qlogis(0.90)  # ≈ 2.20
improved_logit <- qlogis(0.95)  # ≈ 2.94

# Difference (meaningful improvement):
meaningful_diff <- improved_logit - baseline_logit  # ≈ 0.74

# Set ROPE at half of meaningful:
rope_bounds <- c(-0.37, 0.37)

# Now use in analysis:
rope(accuracy_model, range = rope_bounds)
```

---

## 4. Add Critical Caveat: When ROPE Can Mislead

**Insight from Kruschke Section 12.2.1.1 "Bayes factor can accept null with poor precision"**

**This is CRUCIAL and missing from most ROPE tutorials!**

### The Precision Problem

**From Kruschke p. 347:** Even with very little data, you can "accept" the null if the posterior is flat enough!

**Dangerous Example:**

```r
# Scenario: Only 2 coin flips, 1 head, 1 tail
n <- 2; z <- 1

# With uninformative prior Beta(0.01, 0.01):
posterior_alpha <- z + 0.01
posterior_beta <- n - z + 0.01

# The posterior is EXTREMELY FLAT:
x <- seq(0, 1, length.out = 1000)
posterior_density <- dbeta(x, posterior_alpha, posterior_beta)

# 95% HDI is HUGE:
library(HDInterval)
hdi(qbeta, shape1 = posterior_alpha, shape2 = posterior_beta)
# Result: [0.026, 0.974] ← Almost the entire range!

# But with ROPE = [0.45, 0.55], you might claim:
# "The effect is consistent with the null"
# THIS IS WRONG - you simply have NO INFORMATION!
```

**Kruschke's solution:** 

> "High precision demands a large sample size... But when we are trying to accept a specific value of θ, it seems logically appropriate that we should have a reasonably precise estimate indicating that specific value." (p. 348)

**Add to module:**

::: {.callout-warning}
## ROPE Requires Adequate Precision!

Before using ROPE to **accept** the null (claim negligible effect), check:

1. **HDI width**: Is it narrow enough to be meaningful?
   - For RT effects: HDI width < 0.05 log-units (rule of thumb)
   - For accuracy: HDI width < 0.10 on probability scale
   
2. **Effective sample size**: Are ESS values > 1000?
   
3. **Posterior predictive checks**: Does model capture data well?

**Wrong interpretation:**
- "HDI inside ROPE → Effect is negligible" ✗

**Correct interpretation:**  
- "HDI is narrow AND inside ROPE → Effect is negligible" ✓
- "HDI is wide and inside ROPE → Insufficient data" ✓

**Example check:**

```r
# Extract posterior draws
post <- as_draws_df(rt_model)

# Check HDI width for key parameter
hdi_result <- post %>% 
  select(b_conditionB) %>%
  hdi(ci = 0.95)

hdi_width <- hdi_result$CI_high - hdi_result$CI_low

cat("HDI width:", round(hdi_width, 3), "\n")

if (hdi_width > 0.05) {
  warning("HDI too wide for precise ROPE decision. Consider collecting more data.")
}
```
:::

---

## 5. Add Worked Example: Comparing ROPE with Different Priors

**From Kruschke Section 12.2.1:** Prior sensitivity is crucial for ROPE decisions

**Add demonstration** (after main ROPE section around line 700):

### Prior Sensitivity for ROPE Decisions

ROPE conclusions can change with different priors. Always check sensitivity!

```{r}
#| label: rope-prior-sensitivity
#| cache: true

# Scenario: Small dataset (10 subjects, 20 items per condition)
set.seed(2026)
small_data <- expand_grid(
  subject = factor(1:10),
  item = factor(1:20),
  condition = factor(c("A", "B"))
) %>%
  mutate(
    log_rt = 6.0 + 
             rnorm(n(), 0, 0.15)[as.numeric(subject)] +  # subject RE
             rnorm(n(), 0, 0.10)[as.numeric(item)] +     # item RE
             if_else(condition == "B", 0.04, 0) +        # Small true effect
             rnorm(n(), 0, 0.20)                         # residual
  )

# Prior 1: Weakly informative (module default)
prior_weak <- c(
  prior(normal(0, 0.5), class = b),
  prior(exponential(1), class = sd),
  prior(exponential(2), class = sigma)
)

# Prior 2: More regularizing (skeptical of large effects)
prior_skeptical <- c(
  prior(normal(0, 0.2), class = b),  # Tighter on effects
  prior(exponential(2), class = sd),
  prior(exponential(2), class = sigma)
)

# Prior 3: Less informative (more diffuse)
prior_diffuse <- c(
  prior(normal(0, 1), class = b),  # Less regularization
  prior(exponential(0.5), class = sd),
  prior(exponential(1), class = sigma)
)

# Fit all three models
fit_weak <- brm(
  log_rt ~ condition + (1|subject) + (1|item),
  data = small_data,
  prior = prior_weak,
  seed = 2026,
  refresh = 0
)

fit_skeptical <- brm(
  log_rt ~ condition + (1|subject) + (1|item),
  data = small_data,
  prior = prior_skeptical,
  seed = 2026,
  refresh = 0
)

fit_diffuse <- brm(
  log_rt ~ condition + (1|subject) + (1|item),
  data = small_data,
  prior = prior_diffuse,
  seed = 2026,
  refresh = 0
)

# Compare ROPE decisions
library(bayestestR)

rope_results <- bind_rows(
  rope(fit_weak, parameters = "b_conditionB", range = c(-0.05, 0.05)) %>%
    mutate(prior = "Weakly Informative"),
  rope(fit_skeptical, parameters = "b_conditionB", range = c(-0.05, 0.05)) %>%
    mutate(prior = "Skeptical"),
  rope(fit_diffuse, parameters = "b_conditionB", range = c(-0.05, 0.05)) %>%
    mutate(prior = "Diffuse")
) %>%
  select(prior, CI, ROPE_low, ROPE_high, ROPE_Percentage, everything())

print(rope_results)

# Visualize posteriors with ROPE
library(tidybayes)

bind_rows(
  as_draws_df(fit_weak) %>% mutate(prior = "Weakly Informative"),
  as_draws_df(fit_skeptical) %>% mutate(prior = "Skeptical"),
  as_draws_df(fit_diffuse) %>% mutate(prior = "Diffuse")
) %>%
  ggplot(aes(x = b_conditionB, fill = prior)) +
  geom_rect(xmin = -0.05, xmax = 0.05, 
            ymin = -Inf, ymax = Inf,
            fill = "gray90", alpha = 0.5) +
  stat_halfeye(alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  annotate("text", x = 0, y = 0.5, label = "ROPE", size = 4) +
  labs(
    title = "ROPE Sensitivity to Prior Choice",
    subtitle = "Same data, different priors → different ROPE conclusions",
    x = "Effect of Condition B (log-RT)",
    y = "Posterior Density"
  ) +
  facet_wrap(~ prior, ncol = 1) +
  theme_minimal()
```

**Interpretation guidance to add:**

::: {.callout-important}
## When Priors Matter for ROPE

ROPE conclusions are **robust** when:
- Sample size is large (n > 30 per group)
- Effect is clearly outside or inside ROPE across all reasonable priors
- HDI is narrow (precise estimate)

ROPE conclusions are **sensitive** when:
- Sample size is small (n < 20 per group)  
- HDI barely touches ROPE boundary
- Different priors change the conclusion

**What to do if sensitive:**
1. Report results for multiple priors
2. Acknowledge uncertainty in conclusion
3. Consider collecting more data
4. Use prior predictive checks to justify prior choice
:::

---

## 6. Improve "What To Do When Undecided" Section

**Current Gap:** You mention "undecided" but don't elaborate on options.

**From Kurz/McElreath:** Practical decision-making under uncertainty.

**Suggested Addition:**

### When HDI Overlaps ROPE: Three Options

#### Option 1: Collect More Data (If Feasible)

```r
# Power analysis: How much more data needed?
# Rule of thumb: HDI width inversely proportional to sqrt(n)

current_n <- 100
current_hdi_width <- 0.10  # Current 95% HDI width
desired_hdi_width <- 0.05   # Target HDI width

target_n <- current_n * (current_hdi_width / desired_hdi_width)^2
cat("Need approximately", round(target_n), "observations")

# Bayesian sequential testing:
# - Collect data in batches
# - Re-analyze after each batch
# - Stop when decision is clear OR you run out of resources
```

#### Option 2: Accept Uncertainty and Proceed

```r
# Decision theory: Sometimes "undecided" is the right answer
# Compute expected utility for each decision

# If expected utilities are similar:
# → Accept uncertainty
# → Make decision based on other factors (cost, feasibility)
# → Report the uncertainty transparently
```

#### Option 3: Use Less Conservative Threshold

```r
# Instead of 95% HDI, try 89% HDI
# Rationale: 
# - 89% has nice properties (McElreath, 2020)
# - More compatible with decision-theoretic framework
# - Less arbitrary than 95%

rope(model, ci = 0.89, range = c(-0.05, 0.05))

# Or: Use 90% HDI (compromise)
rope(model, ci = 0.90, range = c(-0.05, 0.05))
```

**Add Flowchart:**

```
HDI Overlaps ROPE?
    │
    ├─→ YES
    │   │
    │   ├─→ Can collect more data? 
    │   │   ├─→ YES → Compute required N, collect data
    │   │   └─→ NO → Continue below
    │   │
    │   ├─→ Try less conservative threshold (89% or 90%)?
    │   │   ├─→ Now decisive? → Report with justification
    │   │   └─→ Still undecided → Continue below
    │   │
    │   └─→ Accept uncertainty
    │       ├─→ Report "undecided" transparently
    │       ├─→ Discuss implications
    │       └─→ Make practical decision based on other factors
    │
    └─→ NO (Decisive)
        └─→ Report conclusion with effect size
```

---

---

## 7. Enhance Reporting Section with Kruschke-Style Completeness

**Current:** Module has basic reporting (around line 2000+)

**Enhancement:** Kruschke emphasizes **complete reporting** of posterior, not just decision

### What to Always Report (Beyond Just "Reject/Accept")

**From Kruschke p. 338:**

> "Reporting the limits of an HDI region is more informative than reporting the declaration of a reject/accept decision. By reporting the HDI and other summary information about the posterior, different readers can apply different ROPEs to decide for themselves whether a parameter is practically equivalent to a null value."

**Complete Reporting Checklist:**

1. **Full posterior summary**
   - Point estimate (mean or median)
   - 95% HDI (not just "inside" or "outside" ROPE)
   - Posterior SD

2. **ROPE decision with context**
   - ROPE boundaries with justification
   - % of posterior in ROPE
   - Decision (reject/accept/undecided)
   
3. **Effect size interpretability**
   - On model scale (e.g., log-RT)
   - On original scale (e.g., milliseconds or %)
   - Practical meaning

4. **Model details**
   - Prior specification
   - Convergence diagnostics (R̂, ESS)
   - Sample size

**Example to add:**

### Results Section Template

```markdown
**Example: Well-Reported ROPE Analysis**

We examined whether experimental Condition B affected reading times relative 
to Condition A using a Bayesian mixed-effects model with log-transformed RTs.

**Model specification:** Random intercepts and slopes for subjects, random 
intercepts for items. Priors: N(0, 0.5) for fixed effects, Exp(1) for random 
effect SDs, LKJ(2) for correlations. The model converged successfully (all 
R̂ < 1.01, ESS > 1000).

**Effect estimate:** The posterior mean effect of Condition B was β = 0.12 
log-RT units (95% HDI: [0.09, 0.15], SD = 0.02). This corresponds to a 
12.7% increase in reaction time (95% HDI: [9.4%, 16.2%]).

**Practical significance:** We conducted a ROPE analysis with boundaries of 
±0.05 log-units (±5% RT change), chosen based on prior literature showing 
RT differences below 5% are typically not reliably perceived by participants 
(Smith et al., 2020). The 95% HDI fell entirely outside the ROPE, with 100% 
of the posterior mass indicating a practically meaningful effect.

**Sensitivity:** We refitted the model with more diffuse priors (N(0, 1) for 
fixed effects). The ROPE conclusion remained unchanged (99.8% outside ROPE), 
indicating robustness to prior specification.

**Conclusion:** Condition B produces a moderate but practically meaningful 
slowdown in reading times, well beyond the threshold of practical equivalence.
```

**What NOT to report** (common mistakes):

```markdown
# TOO BRIEF (WRONG):
"The effect was significant (p < .05) with ROPE."

# BETTER BUT INCOMPLETE:
"The 95% HDI excluded the ROPE, so we reject the null hypothesis."

# COMPLETE (CORRECT):
"The effect was β = 0.12 (95% HDI: [0.09, 0.15]), corresponding to 12.7% 
RT increase. With ROPE = ±0.05 (justified by perceptual threshold), 100% 
of posterior mass fell outside ROPE, indicating practical meaningfulness."
```

---

## 8. Add Section: ROPE vs HDI vs ETI (Clarify Interval Types)

**From Kruschke Section 12.1.4:** Important distinction often confused

### Understanding Different Interval Types

**Problem:** Students often confuse:
- **HDI** (Highest Density Interval)
- **ETI** (Equal-Tailed Interval) 
- **ROPE** (Region of Practical Equivalence)

**They serve different purposes!**

#### 1. HDI (Highest Density Interval)

**Definition:** The narrowest interval containing X% of posterior mass.

**Properties:**
- All points inside have higher density than points outside
- Optimal for asymmetric distributions
- Default in bayestestR and tidybayes

```r
# For symmetric posterior: HDI ≈ ETI
# For skewed posterior: HDI ≠ ETI

# Example: Skewed distribution
library(HDInterval)
set.seed(2026)
samples <- rgamma(10000, shape = 2, rate = 0.5)

hdi_vals <- hdi(samples, credMass = 0.95)
eti_vals <- quantile(samples, probs = c(0.025, 0.975))

cat("HDI:", round(hdi_vals, 2), "\n")
cat("ETI:", round(eti_vals, 2), "\n")
# HDI is narrower and shifted right
```

#### 2. ETI (Equal-Tailed Interval)  

**Definition:** 2.5% in each tail (for 95% interval).

**Properties:**
- Symmetric by construction (2.5% + 95% + 2.5%)
- What brms reports by default in summary()
- Easier to compute analytically

```r
# brms uses ETI in summary output:
summary(fit)$fixed
# "l-95% CI" and "u-95% CI" are 2.5% and 97.5% quantiles
```

**When it matters:**

```r
# For symmetric posteriors: HDI ≈ ETI (use either)
# For skewed posteriors: HDI is narrower and more interpretable

# Practical rule:
# - Use HDI for ROPE decisions (most efficient)
# - Use ETI if journal requires it (more familiar to reviewers)
```

#### 3. ROPE (Region of Practical Equivalence)

**Definition:** **NOT an interval** - it's a **region defining equivalence**!

**Properties:**
- Set by researcher before analysis
- Defines "too small to matter"
- Used to evaluate HDI (or ETI)

::: {.callout-note}
## The Relationship

```
ROPE is a REGION (defined by you)
HDI is an INTERVAL (from the posterior)

ROPE decision:
- If HDI excludes ROPE → Meaningful effect
- If HDI inside ROPE → Negligible effect  
- If HDI overlaps ROPE → Undecided
```
:::

**Visualization:**

```r
library(tidyverse)

# Simulate three posteriors
set.seed(2026)
posteriors <- tibble(
  distribution = rep(c("Normal (symmetric)", 
                       "Gamma (right-skewed)", 
                       "Beta (left-skewed)"), 
                     each = 10000),
  value = c(
    rnorm(10000, 0.15, 0.03),
    rgamma(10000, shape = 25, rate = 150),  # right skewed
    rbeta(10000, 20, 5) * 0.3  # left skewed, scaled
  )
)

# Compute HDI and ETI for each
intervals <- posteriors %>%
  group_by(distribution) %>%
  summarise(
    hdi_lower = HDInterval::hdi(value)[1],
    hdi_upper = HDInterval::hdi(value)[2],
    eti_lower = quantile(value, 0.025),
    eti_upper = quantile(value, 0.975),
    .groups = "drop"
  )

# Plot
posteriors %>%
  ggplot(aes(x = value)) +
  # ROPE region (same for all)
  geom_rect(xmin = -0.05, xmax = 0.05,
            ymin = -Inf, ymax = Inf,
            fill = "gray90", alpha = 0.5) +
  # Posterior distribution
  geom_density(fill = "steelblue", alpha = 0.3) +
  # HDI (thick line)
  geom_segment(data = intervals,
               aes(x = hdi_lower, xend = hdi_upper,
                   y = 0, yend = 0),
               color = "darkblue", linewidth = 2) +
  # ETI (thin line, slightly offset)
  geom_segment(data = intervals,
               aes(x = eti_lower, xend = eti_upper,
                   y = -0.5, yend = -0.5),
               color = "darkred", linewidth = 1) +
  annotate("text", x = 0, y = 15, label = "ROPE", size = 3) +
  annotate("text", x = 0.22, y = 3, label = "HDI", 
           color = "darkblue", fontface = "bold") +
  annotate("text", x = 0.22, y = 1, label = "ETI", 
           color = "darkred", fontface = "bold") +
  facet_wrap(~ distribution, scales = "free_y", ncol = 1) +
  labs(x = "Parameter Value", y = "Density",
       title = "HDI vs ETI vs ROPE",
       subtitle = "HDI is narrower for skewed distributions") +
  theme_minimal()
```

**Key takeaway:**

- **HDI/ETI:** Summarize your posterior uncertainty
- **ROPE:** Defines your decision boundary
- **ROPE decision:** Compare HDI against ROPE region

---

## 9.

**From Kurz Chapter:** Mentions classical equivalence testing.

**Suggested Comparison Table:**

### ROPE vs. Frequentist Equivalence Testing (TOST)

| Aspect | TOST (Frequentist) | ROPE (Bayesian) |
|--------|-------------------|-----------------|
| **Question** | "Is effect within bounds?" | "Is effect negligible?" |
| **Output** | p-value (binary decision) | % in ROPE (continuous evidence) |
| **Decisions** | 2 (equivalent or not) | 3 (accept H₀, accept H₁, undecided) |
| **Uncertainty** | Only via p-value | Full posterior distribution |
| **Prior info** | Cannot incorporate | Can incorporate via priors |
| **Multiple comparisons** | Requires adjustment | Natural in Bayesian framework |
| **Interpretation** | "If null true, p(data) = ..." | "Given data, p(null) = ..." |

**Both Require:**
- Pre-specified equivalence bounds ✓
- Domain knowledge ✓
- A priori specification (not post-hoc) ✓

**Example Code Comparison:**

```r
# Frequentist TOST (using TOSTER package)
library(TOSTER)
TOSTtwo(
  m1 = mean_A, m2 = mean_B,
  sd1 = sd_A, sd2 = sd_B,
  n1 = n_A, n2 = n_B,
  low_eqbound = -0.05, high_eqbound = 0.05
)

# Bayesian ROPE (using bayestestR)
rope(brms_model, range = c(-0.05, 0.05))
```

**When to Use Each:**
- **TOST:** When journal/field requires frequentist approach
- **ROPE:** When you want continuous evidence and full posterior

---

## 7. Improve "Reporting" Section with APA-Style Example

**Current:** Basic reporting template.

**Enhancement from Kurz:** More complete methods section.

### Complete APA-Style Reporting Example

```markdown
**Methods**

We fitted a Bayesian mixed-effects model predicting log-transformed reaction 
times from experimental condition (A vs. B), with random intercepts and slopes 
for subjects and random intercepts for items. We used weakly informative priors: 
normal(0, 0.5) for fixed effects, exponential(1) for random effect standard 
deviations, and lkj(2) for correlations among random effects. The model was 
estimated using Hamiltonian Monte Carlo with 4 chains of 2,000 iterations each 
(1,000 warmup). Convergence was verified via R-hat < 1.01 and ESS > 400 for 
all parameters. All analyses were conducted in R (version 4.3.2) using brms 
(version 2.20.4; Bürkner, 2017).

To assess practical significance, we conducted a Region of Practical Equivalence 
(ROPE) analysis (Kruschke, 2018) with boundaries of ±0.05 log-units, corresponding 
to ±5% differences in reaction time on the original scale. These boundaries were 
defined a priori based on pilot data (N = 20) showing that RT differences smaller 
than 5% were not reliably perceived by participants in post-experiment debriefing.

**Results**

The effect of Condition B relative to Condition A was β = 0.12 log-units 
(95% HDI: [0.09, 0.15]). The entire 95% highest density interval fell outside 
the ROPE, with 100% of the posterior mass indicating a practically meaningful 
effect (0% within ROPE). On the original RT scale, Condition B elicited reaction 
times that were 12.7% slower than Condition A (95% HDI: [9.4%, 16.2%]), 
substantially exceeding our pre-registered threshold of 5%.

We verified robustness by refitting the model with more diffuse priors 
(normal(0, 1) for fixed effects). The ROPE decision remained unchanged, with 
99.8% of posterior mass outside ROPE. Model comparison using leave-one-out 
cross-validation (LOO-CV) favored the model including the condition effect 
over an intercept-only model (ΔELPD = 23.4, SE = 5.2).
```

**Key Elements to Always Include:**
1. ✓ Prior specification (with rationale or "weakly informative")
2. ✓ ROPE boundaries (with justification and original-scale interpretation)
3. ✓ When boundaries were set (a priori)
4. ✓ % of posterior in/outside ROPE
5. ✓ Effect size with HDI on both model scale and original scale
6. ✓ Robustness checks (prior sensitivity, model comparison)

---


---

## 9. Add Practical Example: Multi-Parameter ROPE Analysis

**From Kruschke Ch 12:** Real analyses often involve multiple parameters

**Current module:** Only tests single condition effect

**Add:** Factorial design with multiple ROPE tests

### Example: 2×2 Factorial Design with ROPE

```{r}
#| label: rope-factorial-example
#| cache: true

# Generate 2×2 design data
set.seed(2026)
factorial_data <- expand_grid(
  subject = factor(1:40),
  item = factor(1:30),
  factor_a = factor(c("A1", "A2")),
  factor_b = factor(c("B1", "B2"))
) %>%
  mutate(
    # Main effects and interaction
    effect_a = if_else(factor_a == "A2", 0.08, 0),  # Moderate effect
    effect_b = if_else(factor_b == "B2", 0.03, 0),  # Small effect  
    interaction = if_else(factor_a == "A2" & factor_b == "B2", -0.06, 0),
    # Random effects
    subj_intercept = rnorm(1, 0, 0.15)[as.numeric(subject)],
    item_intercept = rnorm(1, 0, 0.10)[as.numeric(item)],
    # Generate log-RT
    log_rt = 6.0 + subj_intercept + item_intercept + 
             effect_a + effect_b + interaction +
             rnorm(n(), 0, 0.18)
  ) %>%
  select(subject, item, factor_a, factor_b, log_rt)

# Fit factorial model
factorial_model <- brm(
  log_rt ~ factor_a * factor_b + (1|subject) + (1|item),
  data = factorial_data,
  prior = c(
    prior(normal(0, 0.5), class = b),
    prior(exponential(1), class = sd),
    prior(exponential(2), class = sigma)
  ),
  seed = 2026,
  refresh = 0
)

# Test ROPE for each effect
library(bayestestR)

# Main effect of Factor A
rope_a <- rope(factorial_model, 
               parameters = "b_factor_aA2",
               range = c(-0.05, 0.05))

# Main effect of Factor B  
rope_b <- rope(factorial_model,
               parameters = "b_factor_bB2", 
               range = c(-0.05, 0.05))

# Interaction
rope_interaction <- rope(factorial_model,
                         parameters = "b_factor_aA2:factor_bB2",
                         range = c(-0.05, 0.05))

# Summary table
bind_rows(
  rope_a %>% mutate(Effect = "Main Effect: Factor A"),
  rope_b %>% mutate(Effect = "Main Effect: Factor B"),
  rope_interaction %>% mutate(Effect = "Interaction: A × B")
) %>%
  select(Effect, CI, ROPE_low, ROPE_high, ROPE_Percentage) %>%
  mutate(
    Decision = case_when(
      ROPE_Percentage == 0 ~ "Reject H0 (Meaningful)",
      ROPE_Percentage == 100 ~ "Accept H0 (Negligible)",
      TRUE ~ "Undecided"
    )
  ) %>%
  knitr::kable(digits = 2, caption = "ROPE Analysis for Factorial Design")
```

**Interpretation:**

```r
# Expected output:
# - Factor A: 0% in ROPE → Meaningful main effect
# - Factor B: 100% in ROPE → Negligible main effect
# - Interaction: ~40% in ROPE → Undecided (overlapping)

# What to report:
# "Factor A showed a meaningful main effect (β = 0.08, 95% HDI: [0.05, 0.11]),
#  with 0% of posterior mass in ROPE = ±0.05. Factor B's effect was negligible
#  (β = 0.03, 95% HDI: [0.00, 0.06]), with 100% of posterior inside ROPE.
#  The interaction was undecided (β = -0.06, 95% HDI: [-0.10, -0.02]), with
#  40% of posterior in ROPE, suggesting insufficient precision for a clear
#  decision on practical significance."
```

**Visualization:**

```r
# Extract and plot all effects
as_draws_df(factorial_model) %>%
  select(starts_with("b_factor")) %>%
  pivot_longer(everything(), 
               names_to = "parameter", 
               values_to = "value") %>%
  mutate(
    parameter = recode(parameter,
                      "b_factor_aA2" = "Main Effect: Factor A",
                      "b_factor_bB2" = "Main Effect: Factor B",
                      "b_factor_aA2:factor_bB2" = "Interaction: A × B")
  ) %>%
  ggplot(aes(x = value, y = parameter)) +
  # ROPE region
  geom_rect(xmin = -0.05, xmax = 0.05,
            ymin = -Inf, ymax = Inf,
            fill = "gray90", alpha = 0.5) +
  # Posterior distributions
  stat_halfeye(.width = 0.95) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  annotate("text", x = 0, y = 3.5, label = "ROPE", size = 4) +
  labs(
    title = "ROPE Analysis: Factorial Design",
    subtitle = "Shaded region = ROPE (±0.05 log-RT units)",
    x = "Effect Size (log-RT)",
    y = NULL
  ) +
  theme_minimal()
```

::: {.callout-tip}
## Multiple Comparisons and ROPE

**Question:** Do we need to "correct" for multiple ROPE tests?

**Answer:** No! Unlike NHST, Bayesian analysis doesn't require correction:

1. **ROPE is not a p-value:** Each ROPE test reports % of posterior mass
2. **Single posterior:** All parameters estimated jointly in one model
3. **Shrinkage:** Multilevel structure provides automatic regularization

**However:**
- Report ALL tests performed (don't cherry-pick)
- Use consistent ROPE boundaries across comparisons
- Acknowledge uncertainty when results are close to boundary

**From Kruschke (p. 328):**
> "In a Bayesian analysis, there is just one posterior distribution over the 
> parameters... That posterior distribution is unaffected by the intentions of 
> the experimenter, and the posterior distribution can be examined from multiple 
> perspectives however is suggested by insight and curiosity."
:::

---

## 10. Summary: Best Practices Checklist

### Before Analysis

- [ ] **Define ROPE boundaries** based on domain knowledge
- [ ] **Document justification** for boundaries (measurement error, perceptual threshold, effect size conventions)
- [ ] **Pre-register** if possible (or document that ROPE was not data-driven)
- [ ] **Choose appropriate priors** (check with prior predictive checks)

### During Analysis

- [ ] **Check convergence:** R̂ < 1.01, ESS > 1000
- [ ] **Check precision:** HDI width reasonable for your question?
- [ ] **Posterior predictive checks:** Model fits data well?
- [ ] **Extract full posterior:** Not just summary statistics

### ROPE Decision

- [ ] **Compute ROPE:** Use bayestestR or manual calculation
- [ ] **Three outcomes:** Be prepared for reject/accept/**undecided**
- [ ] **Check HDI width:** Is it narrow enough for the decision?
- [ ] **Consider all three:** Don't treat "undecided" as failure

### After Analysis

- [ ] **Report complete posterior:** Mean/median, HDI, SD
- [ ] **Report ROPE details:** Boundaries, justification, % in ROPE
- [ ] **Interpret on multiple scales:** Model scale AND original scale
- [ ] **Test sensitivity:** Refit with different priors if conclusion is close
- [ ] **Visualize:** Show full posterior distribution, not just decision

### Reporting Template

```markdown
## Example Complete Report

**Research Question:** Does factor X affect outcome Y?

**Data:** N = [sample size], [design description]

**Model:** [likelihood] with [random effects structure]
- Priors: [list with justifications]
- Convergence: R̂ < 1.01, ESS > [minimum], no divergences

**ROPE:** ±[value] [units], justified by [domain knowledge source]
- Set a priori based on [rationale]

**Results:**
- Posterior: β = [point estimate] (95% HDI: [lower, upper])
- Original scale: [interpretation in meaningful units]
- ROPE decision: [% in ROPE]% of posterior in ROPE
  → [Reject H0 / Accept H0 / Undecided]

**Sensitivity:** 
- [Describe any sensitivity analyses]
- Conclusion [robust / sensitive] to prior choice

**Interpretation:** [Substantive conclusion in domain terms]
```

---

## Implementation Roadmap

### Priority 1: Essential Additions (Implement First)

1. **Section 1:** NHST problems motivation (~2 pages)
2. **Section 2:** Three-outcome ROPE visualization (~1 page)
3. **Section 4:** Precision caveat (~1.5 pages)  
4. **Section 10:** Best practices checklist (~1 page)

**Total:** ~5.5 pages, transforms module from "how to use ROPE" to "how to use ROPE correctly"

### Priority 2: Important Enhancements

5. **Section 3:** Expanded boundary justification (~2 pages)
6. **Section 5:** Prior sensitivity demonstration (~2 pages)
7. **Section 7:** Enhanced reporting (~2 pages)

**Total:** ~6 pages, adds depth and rigor

### Priority 3: Advanced Topics

8. **Section 8:** HDI vs ETI clarification (~2 pages)
9. **Section 9:** Multi-parameter factorial example (~3 pages)

**Total:** ~5 pages, handles complex cases

### Where to Add Each Section

**In 06_rope.qmd:**

- Section 1 → After line 65 (after "Why Practical Significance Matters")
- Section 2 → Around line 400 (expand current ROPE definition)
- Section 3 → Around line 450 (expand boundary justification)
- Section 4 → Around line 700 (after main ROPE demonstration)
- Section 5 → Around line 750 (new section on sensitivity)
- Section 7 → Around line 2000+ (expand current reporting)
- Section 8 → Around line 600 (before ROPE examples)
- Section 9 → Around line 1500 (after emmeans section)
- Section 10 → End of document (before references)

---

## Key References to Add

### Primary Sources

1. **Kruschke, J. K. (2015).** *Doing Bayesian data analysis: A tutorial with R, JAGS, and Stan* (2nd ed.). Academic Press.
   - Chapter 11: Null hypothesis significance testing
   - Chapter 12: Bayesian approaches to testing a point null hypothesis
   - **Especially:** Section 12.1 (estimation approach) and 12.2 (model comparison)

2. **Kruschke, J. K. (2018).** Rejecting or accepting parameter values in Bayesian estimation. *Advances in Methods and Practices in Psychological Science*, 1(2), 270-280.
   - **The definitive ROPE paper**

3. **Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., & Rubin, D. B. (2013).** *Bayesian data analysis* (3rd ed.). CRC Press.
   - Chapter 9: Decision analysis

### Supporting Resources

4. **Lakens, D., Scheel, A. M., & Isager, P. M. (2018).** Equivalence testing for psychological research: A tutorial. *Advances in Methods and Practices in Psychological Science*, 1(2), 259-269.
   - For ROPE vs TOST comparison

5. **Kurz, A. S. (2023).** *Doing Bayesian data analysis in brms and the tidyverse* (Version 0.5.0). https://bookdown.org/content/3686/
   - Chapters 11-12: R/brms implementation of Kruschke
   - **Excellent worked examples**

6. **Makowski, D., Ben-Shachar, M. S., & Lüdecke, D. (2019).** bayestestR: Describing effects and their uncertainty, existence and significance within the Bayesian framework. *Journal of Open Source Software*, 4(40), 1541.
   - Documentation for rope() function

---

## What Makes These Improvements Different

### Compared to Original Suggestions Document

**Original focus:** Added methods (zero-inflated models, mixtures)

**New focus:** Deeper understanding of ROPE fundamentals

**Why the change:**
1. **Kruschke Ch 11-12 is about ROPE**, not mixture models
2. **Module 06 is about decisions**, not model extensions
3. **Fundamentals first:** Students need to understand ROPE deeply before extensions
4. **Practical utility:** Precision caveats and reporting are immediately useful

### What's New

1. **NHST motivation** (missing from most tutorials)
2. **Precision requirements** (critical but often ignored)
3. **Prior sensitivity** (essential for robustness)
4. **Complete reporting** (beyond binary decisions)
5. **HDI vs ETI clarification** (common confusion point)
6. **Multi-parameter workflow** (real-world complexity)
7. **Best practices checklist** (actionable guidance)

### Pedagogical Approach

**Structure:** Practice → Theory → Application
- See ROPE in action first (current module does this well)
- Understand why it works (new Section 1-2)
- Apply with rigor (new Sections 4-10)

**Emphasis:** Critical thinking over mechanical application
- When ROPE can mislead (Section 4)
- How to check robustness (Section 5)
- What to report and why (Section 7)

---

## Estimated Page Counts

| Priority | Sections | Pages | Content Type |
|----------|----------|-------|--------------|
| 1 (Essential) | 1, 2, 4, 10 | ~5.5 | Foundations + caveats |
| 2 (Important) | 3, 5, 7 | ~6 | Justification + robustness |
| 3 (Advanced) | 8, 9 | ~5 | Technical details + examples |
| **Total** | **All** | **~16.5** | **Complete enhancement** |

**Current module:** ~55 pages (HTML)
**With Priority 1:** ~60 pages (10% increase, essential improvements)
**With Priority 1+2:** ~66 pages (20% increase, comprehensive)  
**With all:** ~71 pages (30% increase, exhaustive)

**Recommendation:** Implement Priority 1 + 2 (~11.5 pages) for optimal balance of depth and length.

---

**From Kurz:** Discusses common pitfalls with worked examples.

**Suggested Addition:**

### Gallery of Common ROPE Mistakes (With Fixes)

#### Mistake 1: ROPE Too Narrow

```r
# WRONG: ROPE narrower than measurement error
rope(model, range = c(-0.01, 0.01))  # Only 1% RT difference

# Problem: Measurement error ≈ 20ms (2%), so this ROPE is unrealistic
# Nothing will ever be "negligible" by this standard

# FIX: Set ROPE wider than measurement error
rope(model, range = c(-0.03, 0.03))  # 3% RT difference (> measurement error)
```

#### Mistake 2: Post-Hoc ROPE Adjustment

```r
# WRONG: Looking at results, then adjusting ROPE
summary(model)  # Effect = 0.08
rope(model, range = c(-0.07, 0.07))  # Chosen to exclude effect!

# Problem: This is p-hacking in Bayesian clothing

# FIX: Set ROPE before analysis, document justification
# In pre-registration or analysis plan:
rope_bounds <- c(-0.05, 0.05)  # Based on perceptual threshold
rope(model, range = rope_bounds)
```

#### Mistake 3: Ignoring "Undecided"

```r
# WRONG: Reporting only "significant" or "negligible"
rope_result <- rope(model, range = c(-0.05, 0.05))
# If undecided → Don't report

# Problem: Selective reporting, hides uncertainty

# FIX: Always report ROPE result, including undecided
if (undecided) {
  cat("ROPE analysis was inconclusive (HDI overlaps ROPE)")
  cat("This indicates insufficient precision for this decision")
  cat("Options: collect more data or accept uncertainty")
}
```

#### Mistake 4: Using ROPE When You Mean Bayes Factor

```r
# WRONG: Using ROPE to test "is there an effect?"
rope(model, range = c(-0.0001, 0.0001))  # Extremely narrow ROPE

# Problem: This tests point null (β = 0), not practical equivalence
# For this, use Bayes Factors (Module 07)

# FIX: Use ROPE for practical significance, BF for existence
# ROPE: "Does the effect matter?"
rope(model, range = c(-0.05, 0.05))

# Bayes Factor: "Is there evidence for any effect?" (Module 07)
hypothesis(model, "conditionB = 0")
```

---

## Implementation Notes

**Where to Add in Current Document:**

- **Sections 3, 7, 10:** Add to existing "Setting ROPE Boundaries" and "Reporting" sections
- **Section 5:** Add new section after "ROPE Analysis Workflow"
- **Sections 1, 2, 6, 9:** Add as new subsections under "When to Use What"
- **Sections 4, 8:** Add as optional "Advanced Topics" appendix

**Estimated Addition:**
- High priority: ~3-4 pages
- Medium priority: ~5-6 pages
- Low priority: ~3-4 pages
- **Total: ~11-14 pages** additional content

## Conclusion: From Mechanical Application to Deep Understanding

### What These Improvements Achieve

**Current module strengths:**
- Clear practical examples ✓
- Working code for ROPE, emmeans, marginaleffects ✓
- Good pedagogical flow (practice before theory) ✓

**What improvements add:**
- **Motivation:** Why Bayesian beats NHST (Section 1)
- **Precision:** When to trust ROPE conclusions (Section 4)
- **Robustness:** How to verify sensitivity (Section 5)
- **Completeness:** What to report beyond decisions (Section 7)
- **Clarity:** Understanding intervals and regions (Section 8)
- **Application:** Complex multi-parameter cases (Section 9)
- **Synthesis:** Best practices checklist (Section 10)

### The Core Message

**ROPE is not just a tool—it's a framework for principled decision-making under uncertainty.**

**The improvements shift emphasis from:**
- "How to run rope()" → "How to make defensible decisions"
- "What's the cutoff?" → "How much uncertainty is acceptable?"
- "Reject or accept?" → "What does the full posterior tell us?"

### For the Workshop

**Minimal viable enhancement (Priority 1 only):**
- Adds critical caveats that prevent misuse
- 5-6 pages, ~1 hour additional teaching time
- Makes module rigorous without overwhelming

**Recommended enhancement (Priority 1 + 2):**
- Comprehensive treatment of ROPE methodology  
- 11-12 pages, ~2 hours additional teaching time
- Prepares students for independent research

**Complete enhancement (All priorities):**
- Exhaustive coverage including edge cases
- 16-17 pages, ~3 hours additional teaching time
- Suitable for advanced workshop or reference material

### Implementation Strategy

1. **Week 1:** Add Sections 1, 2, 4 (essentials)
2. **Week 2:** Add Sections 3, 7 (justification + reporting)
3. **Week 3:** Add Section 10 (best practices)
4. **Later:** Add Sections 5, 8, 9 as time permits

**Total realistic enhancement:** ~8-10 pages over 3 weeks of iterative improvement.

---

## References to Add

- McElreath, R. (2020). *Statistical Rethinking* (2nd ed.). CRC Press.
  - Chapter 12: Monsters and mixtures (zero-inflation, over-dispersion)
  
- Lakens, D., Scheel, A. M., & Isager, P. M. (2018). Equivalence testing for psychological research: A tutorial. *Advances in Methods and Practices in Psychological Science*, 1(2), 259-269.
  - For TOST comparison
  
- Schönbrodt, F. D., Wagenmakers, E.-J., Zehetleitner, M., & Perugini, M. (2017). Sequential hypothesis testing with Bayes factors: Efficiently testing mean differences. *Psychological Methods*, 22(2), 322-339.
  - For sequential testing / sample size planning

---