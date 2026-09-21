# .Rprofile: Auto-detect and configure CmdStan path on R startup
# This ensures brms and cmdstanr can find the Stan compiler without manual configuration
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  tryCatch({
    # Try to get existing CmdStan path (if already configured)
    cmdstan_path <- tryCatch(cmdstanr::cmdstan_path(), error = function(e) NULL)

    # If no path is set or invalid, search for CmdStan installation
    if (is.null(cmdstan_path) || !file.exists(cmdstan_path)) {
      cmdstan_base <- file.path(Sys.getenv("HOME"), ".cmdstan")
      if (dir.exists(cmdstan_base)) {
        possible_paths <- list.dirs(cmdstan_base, recursive = FALSE, full.names = TRUE)
        cmdstan_dirs <- grep("cmdstan-", possible_paths, value = TRUE)
        if (length(cmdstan_dirs) > 0) {
          cmdstan_path <- sort(cmdstan_dirs, decreasing = TRUE)[1]
          cmdstanr::set_cmdstan_path(cmdstan_path)
          cat("✓ CmdStan path set to:", cmdstan_path, "\n")
        }
      } else {
        fallback_paths <- c(
          file.path(Sys.getenv("HOME"), ".cmdstanr", "cmdstan"),
          file.path(Sys.getenv("HOME"), ".local", "share", "cmdstan"),
          "/opt/cmdstan"
        )
        for (path in fallback_paths) {
          if (file.exists(path)) {
            cmdstanr::set_cmdstan_path(path)
            cat("✓ CmdStan path set to:", path, "\n")
            break
          }
        }
      }
    }
  }, error = function(e) {
    # Silently fail if CmdStan setup fails
  })
}
