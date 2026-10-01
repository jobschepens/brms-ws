#!/bin/bash -l
#SBATCH --job-name=render_lme4
#SBATCH --output=render_lme4_%j.out
#SBATCH --error=render_lme4_%j.err
#SBATCH --time=01:30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16gb

# ==============================================================================
# SLURM Job Script: Render Session 29 lme4 Quarto Tutorial on RAMSES HPC
# ==============================================================================
# Uses Apptainer with the BRMS workshop container (from GitHub Container Registry)
# ==============================================================================

set -e

echo "======================================================================"
echo "Starting lme4 Quarto Render on RAMSES"
echo "======================================================================"
echo "Job ID:        $SLURM_JOB_ID"
echo "Node:          $SLURMD_NODENAME"
echo "CPUs allocated: $SLURM_CPUS_PER_TASK"
echo "Memory:        $SLURM_MEM_PER_NODE MB"
echo "Start time:    $(date)"
echo "======================================================================"
echo ""

CONTAINER="$HOME/containers/brms-workshop_working.sif"
QMD_FILE="materials/lme4/session29-lme4-model-criticism.qmd"
OUTPUT_HTML="materials/lme4/session29-lme4-model-criticism.html"

# Auto-detect workspace directory
if [ -n "$SLURM_SUBMIT_DIR" ] && [ -f "$SLURM_SUBMIT_DIR/../$QMD_FILE" ]; then
    WORKSPACE="$(cd "$SLURM_SUBMIT_DIR/.." && pwd)"
elif [ -f "$HOME/github/brms-workshop/$QMD_FILE" ]; then
    WORKSPACE="$HOME/github/brms-workshop"
elif [ -f "$HOME/github/brms-ws/$QMD_FILE" ]; then
    WORKSPACE="$HOME/github/brms-ws"
elif [ -f "$HOME/brms-workshop/$QMD_FILE" ]; then
    WORKSPACE="$HOME/brms-workshop"
else
    WORKSPACE="$HOME/github/brms-workshop"
fi

# Verify container existence
if [ ! -f "$CONTAINER" ]; then
    echo "❌ ERROR: Container not found at $CONTAINER"
    echo "Please pull the container first by running:"
    echo "  cd ~/brms-workshop/scripts && bash pull_container_ramses.sh"
    exit 1
fi

# Verify input file
if [ ! -f "$WORKSPACE/$QMD_FILE" ]; then
    echo "❌ ERROR: Target file $WORKSPACE/$QMD_FILE not found."
    echo "Please deploy workshop materials first via deploy_to_ramses.sh"
    exit 1
fi

cd "$WORKSPACE"

echo "Rendering $QMD_FILE inside container..."
echo "----------------------------------------------------------------------"

apptainer exec \
  --bind "$WORKSPACE:/workspace" \
  --pwd /workspace \
  "$CONTAINER" \
  sh -c '
    export PATH="/usr/lib/rstudio-server/bin/quarto/bin:$PATH"
    echo "R version:"
    R --version | head -n 1
    echo "Quarto version:"
    quarto --version
    echo "Executing Quarto render..."
    quarto render materials/lme4/session29-lme4-model-criticism.qmd --to html
  '

echo ""
echo "======================================================================"
echo "✅ Render completed at: $(date)"
echo "======================================================================"

if [ -f "$WORKSPACE/$OUTPUT_HTML" ]; then
    echo "Rendered HTML created successfully:"
    ls -lh "$WORKSPACE/$OUTPUT_HTML"
else
    echo "⚠️ Warning: $OUTPUT_HTML was not found after execution."
fi

echo "======================================================================"
