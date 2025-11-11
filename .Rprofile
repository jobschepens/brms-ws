# Auto-detect and set CmdStan path
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  tryCatch({
    # Check if CmdStan is already installed
    cmdstan_path <- cmdstanr::cmdstan_path()
    if (is.null(cmdstan_path) || !file.exists(cmdstan_path)) {
      # Try to find CmdStan installation
      possible_paths <- c(
        file.path(Sys.getenv("HOME"), ".cmdstanr", "cmdstan"),
        file.path(Sys.getenv("HOME"), ".local", "share", "cmdstan"),
        "/opt/cmdstan"
      )
      for (path in possible_paths) {
        if (file.exists(path)) {
          cmdstanr::set_cmdstan_path(path)
          break
        }
      }
    }
  }, error = function(e) {
    # Silently fail if CmdStan setup fails
  })
}
