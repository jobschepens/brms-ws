suppressMessages({library(lme4);library(lmerTest);library(ordinal);library(dplyr);library(performance);library(see);library(languageR);library(patchwork)})
data(sizeRatings)
sr <- sizeRatings %>% mutate(Rating_ord = factor(Rating, ordered = TRUE))
m <- clmm(Rating_ord ~ Class + (1 | Word), data = sr)
cm <- check_model(m, type = "discrete_interval", residual_type = "normal", panel = FALSE)
cat("panels:", names(cm), "\n")
pn <- "/home/rstudio/workshop/materials/lme4/tmp_diag_"
for (nm in names(cm)) {
  p <- cm[[nm]]
  cat("---", nm, class(p)[1], "\n")
  f <- paste0(pn, nm, ".png")
  r <- tryCatch({ png(f, width = 6, height = 4, units = "in", res = 72); print(p); dev.off(); "ok" }, error = function(e) { try(dev.off(), silent = TRUE); conditionMessage(e) })
  cat(nm, ":", r, file.info(f)$size, "\n")
}
