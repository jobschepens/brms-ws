## Literature and Resources

### Essential Reading

**Decision Analysis (Theoretical Foundation):**

- **Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., & Rubin, D. B. (2013).** *Bayesian Data Analysis* (3rd ed.). CRC Press.
  - Chapter 8: Model checking and improvement
  - **Chapter 9: Decision analysis** ← Theoretical foundation for ROPE
  - The authoritative textbook on Bayesian inference
  - 📖 Free PDF: [http://www.stat.columbia.edu/~gelman/book/](http://www.stat.columbia.edu/~gelman/book/)

- **Stan Development Team. (2024).** Stan User's Guide: Decision Analysis.
  - [https://mc-stan.org/docs/stan-users-guide/decision-analysis.html](https://mc-stan.org/docs/stan-users-guide/decision-analysis.html)
  - Complete worked example with utility functions
  - Shows how to code decision analysis in Stan
  - **Direct conceptual link to ROPE framework**
  - 📦 **Packages:** Applicable to **brms** (built on Stan)

**ROPE Framework:**

- **Kruschke, J. K. (2018).** Rejecting or accepting parameter values in Bayesian estimation. *Advances in Methods and Practices in Psychological Science*, 1(2), 270-280. 
  - 📖 The definitive paper on ROPE
  - Explains decision rules and practical implementation
  - Discusses HDI + ROPE approach in detail
  - DOI: [10.1177/2515245918771304](https://doi.org/10.1177/2515245918771304)
  - 📦 **Packages:** Conceptual foundation for `bayestestR::rope()`, applicable to any Bayesian package

- **Kruschke, J. K. (2015).** *Doing Bayesian Data Analysis: A Tutorial with R, JAGS, and Stan* (2nd ed.). Academic Press.
  - Chapter 12: Bayesian approaches to testing a point (null) value
  - Chapter 25: Model comparison and ROPE
  - The textbook that popularized ROPE in psychology
  - 📦 **Packages:** JAGS examples (concepts transfer to **brms**, **rstanarm**)

**Hypothesis Testing with brms:**

- **Bürkner, P.-C. (2017).** brms: An R package for Bayesian multilevel models using Stan. *Journal of Statistical Software*, 80(1), 1-28. 
  - DOI: [10.18637/jss.v080.i01](https://doi.org/10.18637/jss.v080.i01)
  - Section 3.4: Hypothesis testing (see Module 07)
  - Official documentation on Bayes Factors
  - 📦 **Packages:** **brms**

- **Bürkner, P.-C. (2021).** Bayesian item response modeling in R with brms and Stan. *Journal of Statistical Software*, 100(5), 1-54.
  - Advanced examples of Bayesian modeling
  - DOI: [10.18637/jss.v100.i05](https://doi.org/10.18637/jss.v100.i05)
  - 📦 **Packages:** **brms** in complex models

**Model Interpretation & Marginal Effects:**

- **Arel-Bundock, V., Greifer, N., & Heiss, A. (2024).** How to Interpret Statistical Models Using marginaleffects for R and Python. *Journal of Statistical Software*, 111(9), 1-32.
  - DOI: [10.18637/jss.v111.i09](https://doi.org/10.18637/jss.v111.i09)
  - Comprehensive tutorial on model interpretation
  - Free book: [https://marginaleffects.com](https://marginaleffects.com)
  - 📦 **Packages:** **marginaleffects** (`predictions()`, `comparisons()`, `hypotheses()`)
  - ✅ Supports brms models natively
  - Alternative to `hypothesis()` with more flexible interface

- **Lenth, R. V. (2016).** Least-squares means: The R Package emmeans. *Journal of Statistical Software*, 69(1), 1-33.
  - DOI: [10.18637/jss.v069.i01](https://doi.org/10.18637/jss.v069.i01)
  - Foundation paper for estimated marginal means
  - 📦 **Packages:** **emmeans** (`emmeans()`, `pairs()`, `contrast()`)
  - ✅ Supports brms models with full Bayesian uncertainty
  - Best for factorial designs with automatic pairwise comparisons

**Savage-Dickey Method (Theoretical Foundation):**

- **Wagenmakers, E.-J., Lodewyckx, T., Kuriyal, H., & Grasman, R. (2010).** Bayesian hypothesis testing for psychologists: A tutorial on the Savage-Dickey method. *Cognitive Psychology*, 60(3), 158-189.
  - DOI: [10.1016/j.cogpsych.2009.12.001](https://doi.org/10.1016/j.cogpsych.2009.12.001)
  - Explains the method behind `hypothesis()` Evidence Ratios
  - Includes WinBUGS code (adaptable to brms)
  - 📦 **Packages:** Theoretical foundation for **brms::hypothesis()** Bayes Factors
  - Includes 3 worked examples (proportions, hierarchical models)

**Applied Linguistics:**

- **Nicenboim, B., Schad, D., & Vasishth, S. (2023).** *An Introduction to Bayesian Data Analysis for Cognitive Science*. 
  - Chapter 5: Comparing two groups
  - Chapter 6: Evaluating hypotheses with Bayes factor (see Module 07)
  - Free online: [https://vasishth.github.io/bayescogsci/](https://vasishth.github.io/bayescogsci/)
  - Focused on psycholinguistics applications
  - 📦 **Packages:** **brms**, **bridgesampling**

- **Vasishth, S., Nicenboim, B., Beckman, M. E., Li, F., & Kong, E. J. (2018).** Bayesian data analysis in the phonetic sciences: A tutorial introduction. *Journal of Phonetics*, 71, 147-161.
  - DOI: [10.1016/j.wocn.2018.07.008](https://doi.org/10.1016/j.wocn.2018.07.008)
  - Tutorial specifically for phonetics/linguistics
  - 📦 **Packages:** **brms**, **rstan**

### Online Tutorials and Books

**Comprehensive brms Resources:**

- **Kurz, A. S. (2023).** *Statistical Rethinking with brms, ggplot2, and the tidyverse* (version 1.3.0).
  - Free online book: [https://bookdown.org/content/3890/](https://bookdown.org/content/3890/)
  - Chapter 3.3: Sampling from the posterior
  - Chapter 7: Ulysses' Compass (model comparison)
  - Recodes McElreath's *Statistical Rethinking* using brms
  - Excellent for understanding workflow integration
  - 📦 **Packages:** **brms**, **tidybayes**, **ggplot2**

- **Kurz, A. S. (2023).** *Applied Longitudinal Data Analysis in brms and the tidyverse*.
  - Free online: [https://bookdown.org/content/4857/](https://bookdown.org/content/4857/)
  - Bayesian analysis in multilevel/longitudinal contexts
  - 📦 **Packages:** **brms**, **tidybayes**, **marginaleffects**

**bayestestR Package:**

- **Makowski, D., Ben-Shachar, M. S., & Lüdecke, D. (2019).** bayestestR: Describing effects and their uncertainty, existence and significance within the Bayesian framework. *Journal of Open Source Software*, 4(40), 1541.
  - DOI: [10.21105/joss.01541](https://doi.org/10.21105/joss.01541)
  - Official paper on bayestestR package
  - 📦 **Packages:** **bayestestR** (`rope()`, `equivalence_test()`, `p_direction()`, `hdi()`)
  - ✅ Works with brms models
  - Used extensively in this module for ROPE analysis

- **bayestestR documentation:** [https://easystats.github.io/bayestestR/](https://easystats.github.io/bayestestR/)
  - Vignettes on ROPE, equivalence testing, Bayes factors
  - Tutorial: "Comparison of Indices of Effect Existence"
  - 📦 **Packages:** **bayestestR** comprehensive reference

### Official Documentation

**brms Documentation:**

- **brms overview:** [https://paulbuerkner.com/brms/](https://paulbuerkner.com/brms/)
  - Package homepage with tutorials
  - Links to vignettes and examples
  - 📦 **Packages:** **brms** (all functions)

- **hypothesis() function reference (Module 07):** [https://paulbuerkner.com/brms/reference/hypothesis.brmsfit.html](https://paulbuerkner.com/brms/reference/hypothesis.brmsfit.html)
  - Complete API documentation for Bayes Factors
  - Examples of syntax and usage
  - Details on Savage-Dickey density ratio computation
  - 📦 **Packages:** **brms::hypothesis()**

- **Paul Bürkner's blog posts on brms:** [https://paulbuerkner.com/software/brms-blogposts.html](https://paulbuerkner.com/software/brms-blogposts.html)
  - Curated list of community blog posts
  - Includes posts on hypothesis testing and model comparison
  - 📦 **Packages:** **brms**, various integration examples

**emmeans Documentation:**

- **emmeans website:** [https://rvlenth.github.io/emmeans/](https://rvlenth.github.io/emmeans/)
  - Comprehensive vignettes on estimated marginal means
  - Vignette: "Basics of estimated marginal means"
  - Vignette: "Working with emmeans objects"
  - Vignette: "Models supported by emmeans" (includes brms!)
  - 📦 **Packages:** **emmeans** complete reference

- **emmeans with Bayesian models:** [https://rvlenth.github.io/emmeans/articles/models.html](https://rvlenth.github.io/emmeans/articles/models.html)
  - Section on brms support
  - How to use with posterior samples
  - 📦 **Packages:** **emmeans** + **brms** integration

**marginaleffects Documentation:**

- **marginaleffects book:** [https://marginaleffects.com](https://marginaleffects.com)
  - Free comprehensive book: "Model to Meaning"
  - Chapters on predictions, comparisons, slopes
  - Section on Bayesian models (brms, rstanarm)
  - 📦 **Packages:** **marginaleffects** complete guide

- **marginaleffects vignettes:** [https://marginaleffects.com/articles/](https://marginaleffects.com/articles/)
  - "Bayesian Models" vignette shows brms integration
  - "Hypothesis Tests and Equivalence Tests"
  - 📦 **Packages:** **marginaleffects** with **brms**

**Stan Documentation:**

- **Stan User's Guide - Bayesian Inference:** [https://mc-stan.org/docs/stan-users-guide/bayesian-inference.html](https://mc-stan.org/docs/stan-users-guide/bayesian-inference.html)
  - Chapter on model comparison (see also Module 07 for hypothesis testing)
  - Technical details on computation
  - 📦 **Packages:** **rstan**, **cmdstanr** (backends for **brms**)

### Philosophical and Methodological Background

- **Wagenmakers, E.-J., Lee, M., Lodewyckx, T., & Iverson, G. J. (2008).** Bayesian versus frequentist inference. In H. Hoijtink, I. Klugkist, & P. A. Boelen (Eds.), *Bayesian evaluation of informative hypotheses* (pp. 181-207). Springer.
  - Comparison of Bayesian and frequentist approaches
  - Philosophy of hypothesis testing
  - 📦 **Packages:** Conceptual (not software-specific)

- **Gelman, A., & Carlin, J. (2014).** Beyond power calculations: Assessing Type S (sign) and Type M (magnitude) errors. *Perspectives on Psychological Science*, 9(6), 641-651.
  - Why effect sizes matter more than significance
  - Relationship to ROPE framework
  - 📦 **Packages:** Conceptual (applicable to all Bayesian packages)

### Community Blogs and Tutorials

**Highly Recommended Blogs:**

- **Solomon Kurz's Blog:** [https://solomonkurz.netlify.app/](https://solomonkurz.netlify.app/)
  - Author of the Statistical Rethinking recoding
  - Regular posts on brms workflows
  - 📦 **Packages:** **brms**, **tidybayes**, **ggplot2**

- **Richard McElreath's Statistical Rethinking 2023 Lectures:** [https://github.com/rmcelreath/stat_rethinking_2023](https://github.com/rmcelreath/stat_rethinking_2023)
  - Video lectures with code examples
  - Though uses rethinking package, concepts transfer to brms
  - 📦 **Packages:** **rethinking** (concepts applicable to **brms**)

- **Matti Vuorre's Blog:** [https://mvuorre.github.io/](https://mvuorre.github.io/)
  - Posts on Bayesian methods in psychology
  - brms examples and visualizations
  - 📦 **Packages:** **brms**, **tidybayes**, **ggplot2**

- **TJ Mahr's Blog:** [https://www.tjmahr.com/](https://www.tjmahr.com/)
  - Co-author of tidybayes
  - Excellent brms + tidyverse integration tutorials
  - 📦 **Packages:** **brms**, **tidybayes**, **ggplot2**

### Package Ecosystem Quick Reference

**Primary tools covered in this module:**

| Package | Main Functions | Use Case | brms Support |
|---------|---------------|----------|--------------|
| **bayestestR** | `rope()`, `equivalence_test()` | ROPE analysis, HDI | ✅ Yes |
| **emmeans** | `emmeans()`, `pairs()`, `contrast()` | Factorial designs, pairwise comparisons | ✅ Yes |
| **marginaleffects** | `predictions()`, `comparisons()`, `hypotheses()` | General predictions, contrasts | ✅ Yes |
| **tidybayes** | `spread_draws()`, `stat_halfeye()` | Posterior visualization | ✅ Yes |
| **brms** | `hypothesis()` | Bayes Factors (see Module 07) | Native (is brms!) |

**When to use each:**

- **`rope()`**: Test practical equivalence (ROPE analysis)
- **`emmeans()`**: Factorial designs with all pairwise comparisons
- **`marginaleffects`**: Most flexible predictions and comparisons
- **`hypothesis()`**: Bayes Factors for hypothesis comparison (Module 07)
- **Combine them!**: Use multiple approaches for robust inference

### Practical Recommendations for Different Audiences

**If you're new to Bayesian statistics:**
1. Start with Kruschke (2015) *Doing Bayesian Data Analysis*
2. Work through Kurz's *Statistical Rethinking with brms*
3. Read Nicenboim et al. (2023) for linguistics applications
4. 📦 Focus on **brms** + **bayestestR** first

**If you're familiar with Bayesian methods but new to brms:**
1. Read Bürkner (2017) JSS paper on brms
2. Work through examples in Kurz's online book
3. 📦 Add **emmeans** or **marginaleffects** for richer comparisons

**If you want to understand ROPE deeply:**
1. **Must read:** Kruschke (2018) paper on ROPE
2. Study Chapter 12 of Kruschke (2015) book
3. Compare with Makowski et al. (2019) bayestestR paper
4. 📦 Use **bayestestR::rope()** for implementation

**If you want to move beyond ROPE for comparisons:**
1. Learn **emmeans** for factorial designs (familiar to traditional stats users)
2. Learn **marginaleffects** for general approach (modern, unified interface)
3. Read Arel-Bundock et al. (2024) JSS paper
4. 📦 Both integrate seamlessly with **brms**

**If you want hypothesis testing:**
1. See Module 07 on Bayes Factors
2. Learn about the Savage-Dickey method
3. 📦 Use **brms::hypothesis()** for implementation

**If you're writing a methods section:**

- Cite Kruschke (2018) for ROPE framework
- Cite Bürkner (2017) for brms package
- Cite Makowski et al. (2019) if using bayestestR
- Cite Lenth (2016) if using emmeans
- Cite Arel-Bundock et al. (2024) if using marginaleffects
- Include your ROPE boundary justification!
- 📦 Always cite the packages you actually use

### Discussion Forums and Help

- **Stan Discourse Forum:** [https://discourse.mc-stan.org/](https://discourse.mc-stan.org/)
  - Very active community
  - Paul Bürkner frequently answers brms questions
  - Search before posting - many questions already answered
  - Topics: **brms**, **Stan**, **cmdstanr**

- **brms GitHub Issues:** [https://github.com/paul-buerkner/brms/issues](https://github.com/paul-buerkner/brms/issues)
  - For bug reports and feature requests
  - Many closed issues are useful troubleshooting resources
  - **brms** specific technical questions

- **Stack Overflow [brms] tag:** [https://stackoverflow.com/questions/tagged/brms](https://stackoverflow.com/questions/tagged/brms)
  - Good for specific coding questions
  - Tags: **brms**, **bayesian**, **stan**

- **marginaleffects GitHub Discussions:** [https://github.com/vincentarelbundock/marginaleffects/discussions](https://github.com/vincentarelbundock/marginaleffects/discussions)
  - Help with **marginaleffects** package
  - Questions about brms integration

- **emmeans support:** [https://github.com/rvlenth/emmeans/issues](https://github.com/rvlenth/emmeans/issues)
  - **emmeans** specific questions
  - Bayesian model support

### Related Workshop Materials

Other modules in this workshop series:

- Module 01-02: Introduction and prior specification
- Module 03: Posterior predictive checks
- Module 04: Prior sensitivity analysis  
- Module 05: Model comparison with LOO
- **Module 06 (this):** ROPE and practical significance
  - 📦 **Key packages:** **brms**, **bayestestR**, **emmeans**, **marginaleffects**
- **Module 07 (next):** Bayes factors and hypothesis comparison
  - 📦 **Key packages:** **brms::hypothesis()**, **bridgesampling**

# Best Practices Checklist for ROPE Analysis

::: {.callout-tip}
## Complete ROPE Analysis Checklist

Use this checklist to ensure your ROPE analysis is rigorous and defensible.
:::

## Before Analysis

**Define ROPE Boundaries**

- [ ] ROPE boundaries defined based on domain knowledge (not data)
- [ ] Justification documented (measurement error, perceptual threshold, effect size conventions, or prior literature)
- [ ] Boundaries set a priori (ideally pre-registered)
- [ ] Boundaries specified on appropriate scale (log-RT, probability, standardized effect)

**Example documentation:**
```
ROPE boundaries: [-0.05, +0.05] log-RT units (corresponding to ±5% RT change)
Justification: Based on pilot study (N=20) showing RT differences < 5% 
               not reliably perceived by participants in debriefing
```

**Choose Appropriate Priors**

- [ ] Priors are weakly informative (not flat or overly restrictive)
- [ ] Prior predictive checks performed (Module 02)
- [ ] Priors documented with rationale

**Example:**
```r
prior <- c(
  prior(normal(0, 0.5), class = b),      # Weakly informative for effects
  prior(exponential(1), class = sd),      # Regularizing for REs
  prior(lkj(2), class = cor)              # Slight regularization for correlations
)
```

## During Analysis

**Check Model Convergence**

- [ ] R̂ < 1.01 for all parameters
- [ ] ESS (bulk) > 1000 for parameters of interest
- [ ] ESS (tail) > 1000 for parameters of interest
- [ ] No divergent transitions or other warnings

```{r}
#| label: convergence-check-example
#| eval: false

# Quick convergence check
summary(rt_model)  # Check Rhat column
# Or more detailed:
library(posterior)
summarise_draws(rt_model) %>%
  filter(rhat > 1.01 | ess_bulk < 1000)  # Should return 0 rows
```

**Check Precision (Critical for Accepting H₀!)**

- [ ] HDI width appropriate for decision (see Section on precision)
- [ ] Posterior SD < half ROPE width (rule of thumb)
- [ ] Not relying on "HDI inside ROPE" with wide uncertainty

```{r}
#| label: precision-check-example
#| eval: false

# Check HDI width
post <- as_draws_df(rt_model)
hdi <- HDInterval::hdi(post$b_conditionB, credMass = 0.95)
hdi_width <- hdi[2] - hdi[1]

cat("HDI width:", round(hdi_width, 4), "\n")
cat("Is it < 0.05? ", hdi_width < 0.05, "\n")  # Threshold for RT effects
```

**Posterior Predictive Checks**

- [ ] Model captures key data features (Module 03)
- [ ] No systematic misfit that could bias effect estimates
- [ ] Residuals reasonably behaved

**Extract Full Posterior**

- [ ] Not relying only on summary statistics
- [ ] Full posterior distribution extracted and visualized
- [ ] Uncertainty properly represented

## ROPE Decision

**Compute ROPE Analysis**

- [ ] Used appropriate credible interval (typically 95%)
- [ ] Checked all three outcomes (reject H₀, accept H₀, undecided)
- [ ] Not forcing binary decision when HDI overlaps ROPE

```{r}
#| label: rope-decision-example
#| eval: false

library(bayestestR)
rope_result <- rope(rt_model, 
                    parameters = "b_conditionB",
                    range = c(-0.05, 0.05),
                    ci = 0.95)
print(rope_result)
```

**Interpret Carefully**

- [ ] **If HDI excludes ROPE:** Effect is practically meaningful
- [ ] **If HDI inside ROPE:** Check precision before claiming negligible!
- [ ] **If HDI overlaps ROPE:** Report as undecided (don't force decision)

**Check HDI Width When Accepting H₀**

- [ ] HDI width < reasonable threshold (e.g., 0.05 for RT effects)
- [ ] ESS > 1000
- [ ] Posterior SD indicates adequate precision
- [ ] If checks fail: Report "insufficient precision" instead of "negligible"

## After Analysis

**Report Complete Posterior**

- [ ] Point estimate (mean or median)
- [ ] 95% HDI (not just "inside/outside ROPE")
- [ ] Posterior SD or other uncertainty measure
- [ ] Interpretation on original scale (not just model scale)

**Example:**
```
The effect of Condition B was β = 0.12 log-RT units (95% HDI: [0.09, 0.15], 
SD = 0.02). On the original scale, this corresponds to a 12.7% increase in 
reaction time (95% HDI: [9.4%, 16.2%]).
```

**Report ROPE Details**

- [ ] ROPE boundaries stated clearly
- [ ] Justification for boundaries provided
- [ ] When boundaries were set (a priori/post-hoc)
- [ ] Percentage of posterior in ROPE
- [ ] Clear decision statement

**Example:**
```
We conducted a ROPE analysis with boundaries of ±0.05 log-units (±5% RT change), 
defined a priori based on perceptual thresholds from Smith et al. (2020). The 
95% HDI fell entirely outside the ROPE, with 100% of posterior mass indicating 
a practically meaningful effect.
```

**Report Effect Size Interpretability**

- [ ] Effect size on model scale (e.g., log-RT, logit)
- [ ] Effect size on original scale (e.g., milliseconds, percentages)
- [ ] Practical meaning in domain terms

**Example:**
```
The 12.7% RT increase corresponds to approximately 45ms for an average baseline 
RT of 350ms, well above the threshold for reliable perception by readers.
```

**Report Model Details**

- [ ] Prior specification documented
- [ ] Convergence diagnostics summarized
- [ ] Sample size (subjects, items, observations) reported
- [ ] Software versions noted

**Sensitivity Checks**

- [ ] Prior sensitivity analyzed if conclusion is close
- [ ] Alternative ROPE boundaries considered if appropriate
- [ ] Model comparison performed (Module 05) if structure uncertain

```{r}
#| label: sensitivity-example
#| eval: false

# Refit with more diffuse prior
prior_diffuse <- c(
  prior(normal(0, 1), class = b),  # Less regularization
  prior(exponential(0.5), class = sd),
  prior(lkj(2), class = cor)
)

rt_model_diffuse <- update(rt_model, prior = prior_diffuse, seed = 2026)

# Check if ROPE conclusion changes
rope(rt_model_diffuse, range = c(-0.05, 0.05))
```

**Visualize**

- [ ] Posterior distribution with ROPE shown
- [ ] HDI clearly marked
- [ ] Decision regions labeled
- [ ] Original scale interpretation included if possible

## Reporting Template

### Methods Section Template

```markdown
We fitted a Bayesian mixed-effects model predicting [outcome] from [predictors], 
with [random effects structure]. We used [prior specification]. The model was 
estimated using Hamiltonian Monte Carlo with 4 chains of 2,000 iterations each 
(1,000 warmup). Convergence was verified via R̂ < 1.01 and ESS > 400 for all 
parameters.

To assess practical significance, we conducted a Region of Practical Equivalence 
(ROPE) analysis (Kruschke, 2018) with boundaries of [values], corresponding to 
[interpretation on original scale]. These boundaries were defined a priori based 
on [justification: e.g., pilot data, measurement precision, perceptual thresholds, 
or prior literature].

All analyses were conducted in R (version X.X.X) using brms (version X.X.X; 
Bürkner, 2017) and bayestestR (version X.X.X; Makowski et al., 2019).
```

### Results Section Template

```markdown
The effect of [predictor] was β = [estimate] (95% HDI: [lower, upper]). The 
[95%/entire] HDI fell [outside/inside] the ROPE, with [X]% of the posterior 
mass indicating a [practically meaningful/negligible] effect. On the original 
[outcome] scale, [predictor] [increased/decreased] [outcome] by [X]% (95% HDI: 
[lower%, upper%]), [well exceeding/falling within] our pre-registered threshold 
of [Y]%.

We verified robustness by refitting the model with [more diffuse/alternative] 
priors. The ROPE decision remained unchanged, with [X]% of posterior mass 
[outside/inside] ROPE.

[If undecided: The 95% HDI overlapped the ROPE boundaries, with [X]% of posterior 
mass inside ROPE. This indicates insufficient precision to make a definitive 
decision about practical significance. We interpret this as suggesting the effect 
may be near the threshold of practical importance, warranting further investigation.]
```

## Common Mistakes to Avoid

**Mistake 1: ROPE Too Narrow**

❌ **Wrong:** ROPE narrower than measurement error
```r
rope(model, range = c(-0.01, 0.01))  # Only 1% RT difference
# Problem: Measurement error ≈ 2%, so ROPE is unrealistic
```

✅ **Right:** ROPE wider than measurement error
```r
rope(model, range = c(-0.03, 0.03))  # 3% RT (> measurement error)
```

**Mistake 2: Post-Hoc ROPE Adjustment**

❌ **Wrong:** Looking at results, then adjusting ROPE
```r
summary(model)  # Effect = 0.08
rope(model, range = c(-0.07, 0.07))  # Chosen to exclude effect!
# Problem: This is p-hacking in Bayesian clothing
```

✅ **Right:** Set ROPE before analysis
```r
# In pre-registration or analysis plan:
rope_bounds <- c(-0.05, 0.05)  # Based on perceptual threshold
rope(model, range = rope_bounds)
```

**Mistake 3: Ignoring "Undecided"**

❌ **Wrong:** Only reporting "significant" or "negligible"
```r
if (undecided) {
  # Don't report this result
}
```

✅ **Right:** Always report ROPE result
```r
if (undecided) {
  cat("ROPE analysis inconclusive (HDI overlaps ROPE)\n")
  cat("Interpretation: Insufficient precision for clear decision\n")
  cat("Options: collect more data or accept uncertainty\n")
}
```

**Mistake 4: Accepting H₀ with Wide HDI**

❌ **Wrong:** "HDI inside ROPE" with wide uncertainty
```r
# HDI: [0.01, 0.04], width = 0.03
# "Effect is negligible" ← Too uncertain!
```

✅ **Right:** Check precision first
```r
hdi_width <- 0.03
if (hdi_width > 0.05) {
  cat("HDI too wide for confident negligible claim\n")
  cat("Report: 'Insufficient precision' or collect more data\n")
}
```

## Key References

- **Kruschke, J. K. (2015).** *Doing Bayesian data analysis* (2nd ed.). Academic Press. [Chapters 11-12]
- **Kruschke, J. K. (2018).** Rejecting or accepting parameter values in Bayesian estimation. *Advances in Methods and Practices in Psychological Science*, 1(2), 270-280.
- **Makowski, D., Ben-Shachar, M. S., & Lüdecke, D. (2019).** bayestestR: Describing effects and their uncertainty. *Journal of Open Source Software*, 4(40), 1541.
- **Lakens, D., Scheel, A. M., & Isager, P. M. (2018).** Equivalence testing for psychological research. *Advances in Methods and Practices in Psychological Science*, 1(2), 259-269.

