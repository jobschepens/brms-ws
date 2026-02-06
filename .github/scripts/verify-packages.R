extract_pkgs <- function(x) {
  out <- character()
  if (is.call(x)) {
    if (identical(x[[1]], as.name("install.packages")) && length(x) >= 2) {
      arg <- x[[2]]
      if (is.character(arg)) out <- c(out, arg)
      if (is.call(arg) && identical(arg[[1]], as.name("c"))) {
        vals <- as.list(arg)[-1]
        out <- c(out, unlist(lapply(vals, function(v) if (is.character(v)) v else character(0))))
      }
    }
    kids <- as.list(x)[-1]
    if (length(kids) > 0) {
      for (k in kids) out <- c(out, extract_pkgs(k))
    }
  }
  out
}

exprs <- parse(file = "/workspace/install.R")
pkgs <- unique(unlist(lapply(as.list(exprs), extract_pkgs)))
cat("Checking", length(pkgs), "declared packages\n")

missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  stop(paste("Missing packages:", paste(missing, collapse = ", ")))
}

cat("All declared packages are installed\n")
