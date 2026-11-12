#!/bin/bash
# ==============================================================================
# Deploy BRMS Workshop & lme4 Tutorial to RAMSES HPC (Uni Köln)
# ==============================================================================

set -e

RAMSES_USER="${RAMSES_USER:-jschepen}"
RAMSES_HOST="${RAMSES_HOST:-ramses1.itcc.uni-koeln.de}"
RAMSES_DIR="${RAMSES_DIR:-projects/brms-workshop}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "======================================================================"
echo "Deploying BRMS Workshop to RAMSES ($RAMSES_HOST)"
echo "======================================================================"
echo "User:       $RAMSES_USER"
echo "Target Dir: ~/$RAMSES_DIR"
echo "Root:       $WORKSPACE_ROOT"
echo ""

# Steps 1-3: stage locally, then use ONE SSH session for mkdir + upload.
# RAMSES sends a Duo push per login, and unapproved pushes block the account,
# so do not split this back into separate ssh/scp calls or add retries.
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/ramses" "$STAGE/materials/lme4"
cp \
  "$SCRIPT_DIR/pull_container_ramses.sh" \
  "$SCRIPT_DIR/test_apptainer.sh" \
  "$SCRIPT_DIR/render_lme4_slurm.sh" \
  "$STAGE/ramses/"
cp \
  "$WORKSPACE_ROOT/materials/lme4/session29-lme4-model-criticism.qmd" \
  "$WORKSPACE_ROOT/materials/lme4/references.bib" \
  "$STAGE/materials/lme4/"

echo "Step 1: Setting up directories and transferring files (one login)..."
echo "Approve the Duo push on your phone now."
tar -C "$STAGE" -cf - . \
  | ssh "${RAMSES_USER}@${RAMSES_HOST}" "
      set -e
      mkdir -p ~/${RAMSES_DIR}/{ramses,data,results,materials/lme4} ~/hpc/containers
      tar -C ~/${RAMSES_DIR} -xf -"

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
echo "3. Pull the container image (only once, ~5-10 min):"
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
