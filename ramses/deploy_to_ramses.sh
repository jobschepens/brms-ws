#!/bin/bash
# ==============================================================================
# Deploy BRMS Workshop & lme4 Tutorial to RAMSES HPC (Uni Köln)
# ==============================================================================

set -e

RAMSES_USER="${RAMSES_USER:-jschepen}"
RAMSES_HOST="${RAMSES_HOST:-ramses1.itcc.uni-koeln.de}"
RAMSES_DIR="${RAMSES_DIR:-github/brms-workshop}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "======================================================================"
echo "Deploying BRMS Workshop to RAMSES ($RAMSES_HOST)"
echo "======================================================================"
echo "User:       $RAMSES_USER"
echo "Target Dir: ~/$RAMSES_DIR"
echo "Root:       $WORKSPACE_ROOT"
echo ""

# Step 1: Ensure directory structure exists on RAMSES
echo "Step 1: Setting up directories on RAMSES..."
ssh "${RAMSES_USER}@${RAMSES_HOST}" \
  "mkdir -p ~/${RAMSES_DIR}/{ramses,data,results,materials/lme4} ~/containers"

echo ""
echo "Step 2: Transferring scripts..."
scp \
  "$SCRIPT_DIR/pull_container_ramses.sh" \
  "$SCRIPT_DIR/test_apptainer.sh" \
  "$SCRIPT_DIR/render_lme4_slurm.sh" \
  "${RAMSES_USER}@${RAMSES_HOST}:~/${RAMSES_DIR}/ramses/"

echo ""
echo "Step 3: Transferring lme4 workshop materials (QMD and references)..."
scp \
  "$WORKSPACE_ROOT/materials/lme4/session29-lme4-model-criticism.qmd" \
  "$WORKSPACE_ROOT/materials/lme4/references.bib" \
  "${RAMSES_USER}@${RAMSES_HOST}:~/${RAMSES_DIR}/materials/lme4/"

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
echo "2. Navigate to ramses folder:"
echo "   cd ~/${RAMSES_DIR}/ramses"
echo ""
echo "3. Pull the GitHub container image (if not already pulled):"
echo "   bash pull_container_ramses.sh"
echo ""
echo "4. Submit the lme4 rendering SLURM job:"
echo "   sbatch render_lme4_slurm.sh"
echo ""
echo "5. Monitor the job:"
echo "   squeue -u \$USER"
echo "   tail -f render_lme4_*.out"
echo ""
echo "6. Check the rendered HTML:"
echo "   ls -lh ~/${RAMSES_DIR}/materials/lme4/session29-lme4-model-criticism.html"
echo "======================================================================"
