#!/bin/bash

# Render all QMD files to both HTML and PDF formats in parallel
# Uses bash background processes for parallel rendering with monitoring

# Get number of available cores
num_cores=$(nproc)
max_jobs=$((num_cores > 4 ? 4 : num_cores))  # Cap at 4 to avoid system overload

echo "Starting rendering of all Quarto documents..."
echo "Using up to $max_jobs parallel jobs (system cores: $num_cores)"
echo ""

# Array of QMD files to render
declare -a files=(
  "01_setting_priors.qmd"
  "01_setting_priors_gram.qmd"
  "02_prior_predictive_checks_rt.qmd"
  "02_prior_predictive_checks_gram.qmd"
  "03_posterior_predictive_checks_rt.qmd"
  "03_posterior_predictive_checks_gram.qmd"
  "04_comparing_priors_rt.qmd"
  "05_loo.qmd"
)

total=${#files[@]}
current=0
failed_count=0
pids=()

# Track which files are being rendered
declare -A pid_to_file

# Render files with parallel job control
for file in "${files[@]}"; do
  ((current++))
  
  # Wait if we have too many background jobs running
  while [ $(jobs -r -p | wc -l) -ge $max_jobs ]; do
    sleep 0.5
  done
  
  # Start rendering in background
  {
    start_time=$(date +%s)
    if quarto render "$file" --to html,pdf > /dev/null 2>&1; then
      end_time=$(date +%s)
      duration=$((end_time - start_time))
      echo "[$current/$total] ✓ $file (${duration}s)"
    else
      echo "[$current/$total] ✗ $file (FAILED)"
      exit 1
    fi
  } &
  
  pid=$!
  pids+=($pid)
  pid_to_file[$pid]=$file
  echo "[$current/$total] Starting: $file (PID: $pid)"
done

# Wait for all background jobs and collect results
exit_code=0
for pid in "${pids[@]}"; do
  if wait $pid 2>/dev/null; then
    :
  else
    ((failed_count++))
    exit_code=1
  fi
done

echo ""
echo "================================"
if [ $exit_code -eq 0 ]; then
  echo "✓ All $total documents rendered successfully!"
else
  echo "✗ $failed_count of $total documents failed"
fi
echo "================================"
echo "Output files:"
echo "  HTML: *.html"
echo "  PDF:  *.pdf"
ls -lh *.html *.pdf 2>/dev/null | tail -5
echo "================================"

exit $exit_code
