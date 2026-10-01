#!/bin/bash
# ==============================================================================
# Deploy BRMS Workshop & lme4 Tutorial to RAMSES HPC (Uni Köln)
# ==============================================================================

set -e

RAMSES_USER="${RAMSES_USER:-jschepen}"
RAMSES_HOST="${RAMSES_HOST:-ramses1.itcc.uni-koeln.de}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "======================================================================"
echo "Deploying BRMS Workshop to RAMSES ($RAMSES_HOST)"
echo "======================================================================"
echo "User: $RAMSES_USER"
echo "Root: $WORKSPACE_ROOT"
echo ""

# Step 1: Ensure directory structure exists on RAMSES
echo "Step 1: Setting up directories on RAMSES..."
ssh "${RAMSES_USER}@${RAMSES_HOST}" \
  "mkdir -p ~/brms-workshop/{scripts,data,results,materials/lme4} ~/containers"

echo ""
echo "Step 2: Transferring scripts..."
scp \
  "$SCRIPT_DIR/pull_container_ramses.sh" \
  "$SCRIPT_DIR/test_apptainer.sh" \
  "$SCRIPT_DIR/render_lme4_slurm.sh" \
  "${RAMSES_USER}@${RAMSES_HOST}:~/brms-workshop/scripts/"

echo ""
echo "Step 3: Transferring lme4 workshop materials (QMD and references)..."
scp \
  "$WORKSPACE_ROOT/materials/lme4/session29-lme4-model-criticism.qmd" \
  "$WORKSPACE_ROOT/materials/lme4/references.bib" \
  "${RAMSES_USER}@${RAMSES_HOST}:~/brms-workshop/materials/lme4/"

echo ""
echo "======================================================================"
echo "✅ Deployment completed successfully!"
echo "======================================================================"
echo ""
echo "Commands to execute on RAMSES:"
echo ""
echo "1. Connect via SSH:"
echo "   ssh ${RAMSES_USER}@${RAMSES_HOST}"
echo ""
echo "2. Pull the GitHub container image (only once, ~5-10 min):"
echo "   cd ~/brms-workshop/scripts"
echo "   bash pull_container_ramses.sh"
echo ""
echo "3. Submit the lme4 rendering SLURM job:"
echo "   cd ~/brms-workshop/scripts"
echo "   sbatch render_lme4_slurm.sh"
echo ""
echo "4. Monitor the job:"
echo "   squeue -u \$USER"
echo "   tail -f ~/brms-workshop/scripts/render_lme4_*.out"
echo ""
echo "5. Check the rendered HTML:"
echo "   ls -lh ~/brms-workshop/materials/lme4/session29-lme4-model-criticism.html"
echo "======================================================================"
