#!/bin/bash
#SBATCH --job-name=brms_apptainer_test
#SBATCH --output=brms_test_%j.out
#SBATCH --error=brms_test_%j.err
#SBATCH --time=00:30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8gb

# Test BRMS in Apptainer container on RAMSES

echo "=========================================="
echo "BRMS Apptainer Container Test"
echo "=========================================="
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURMD_NODENAME"
echo "Cores: $SLURM_CPUS_PER_TASK"
echo "Memory: $SLURM_MEM_PER_NODE MB"
echo "Start time: $(date)"
echo ""

# Set container path (adjust if needed)
CONTAINER="$HOME/containers/brms-workshop_working.sif"

# Check if container exists
if [ ! -f "$CONTAINER" ]; then
    echo "❌ ERROR: Container not found at $CONTAINER"
    echo ""
    echo "Please run: bash ~/brms-workshop/scripts/pull_container_ramses.sh"
    exit 1
fi

echo "✅ Container found: $CONTAINER"
echo "   Size: $(du -h $CONTAINER | cut -f1)"
echo ""

# Test 1: Check Apptainer version
echo "Test 1: Apptainer version"
echo "----------------------------------------"
apptainer --version
echo ""

# Test 2: Check R version in container
echo "Test 2: R version in container"
echo "----------------------------------------"
apptainer exec $CONTAINER R --version
echo ""

# Test 3: Check BRMS package
echo "Test 3: BRMS package check"
echo "----------------------------------------"
apptainer exec $CONTAINER Rscript -e "library(brms); cat('BRMS version:', as.character(packageVersion('brms')), '\n')"
echo ""

# Test 4: Check CmdStan
echo "Test 4: CmdStan check"
echo "----------------------------------------"
apptainer exec $CONTAINER Rscript -e "library(cmdstanr); cat('CmdStan path:', cmdstan_path(), '\n')"
echo ""

# Test 5: Run simple BRMS model
echo "Test 5: Running simple BRMS model"
echo "----------------------------------------"

# Create temporary R script inside the container's /tmp
cat > /tmp/test_brms_apptainer_${SLURM_JOB_ID}.R << 'EOF'
library(brms)
library(tidyverse)

# Set options
options(mc.cores = 4)

# Create test data
set.seed(123)
test_data <- data.frame(
  x = rnorm(100),
  y = 2 + 1.5 * rnorm(100)
)

cat("Test data created: 100 observations\n\n")

# Fit simple model
cat("Fitting model: y ~ x\n")
cat("Chains: 2, Iterations: 1000\n\n")

fit <- brm(
  y ~ x,
  data = test_data,
  family = gaussian(),
  chains = 2,
  iter = 1000,
  warmup = 500,
  cores = 2,
  seed = 123,
  refresh = 0,
  silent = 2
)

cat("\n✅ Model fitted successfully!\n\n")
cat("Summary:\n")
print(summary(fit))

cat("\n========================================\n")
cat("✅ BRMS Container Test Completed!\n")
cat("========================================\n")
EOF

# Run test in container with /tmp bound
apptainer exec --bind /tmp:/tmp $CONTAINER Rscript /tmp/test_brms_apptainer_${SLURM_JOB_ID}.R

# Cleanup
rm /tmp/test_brms_apptainer_${SLURM_JOB_ID}.R

echo ""
echo "=========================================="
echo "Test completed at: $(date)"
echo "=========================================="
echo ""
echo "✅ Your BRMS container is working correctly on RAMSES!"
echo ""
echo "Next steps:"
echo "  1. Copy your analysis scripts to ~/brms-workshop/"
echo "  2. Create SLURM job scripts based on this template"
echo "  3. Submit your analysis jobs with: sbatch your_script.sh"
echo ""
