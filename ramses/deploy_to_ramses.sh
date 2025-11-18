#!/bin/bash
# Deploy BRMS workflow to RAMSES using Apptainer

set -e

RAMSES_USER="jschepen"
RAMSES_HOST="ramses1.itcc.uni-koeln.de"

echo "=========================================="
echo "Deploying BRMS to RAMSES"
echo "=========================================="
echo ""
echo "Note: This will require 3 Cisco Duo authentications"
echo "      (one for each SSH connection)"
echo ""

# Create directories on RAMSES
echo "Step 1: Creating directories on RAMSES..."
ssh ${RAMSES_USER}@${RAMSES_HOST} "mkdir -p ~/brms-workshop/{scripts,data,results,materials}"

echo ""
echo "Step 2: Transferring Apptainer scripts..."
scp pull_container_ramses.sh ${RAMSES_USER}@${RAMSES_HOST}:~/brms-workshop/scripts/
scp test_apptainer.sh ${RAMSES_USER}@${RAMSES_HOST}:~/brms-workshop/scripts/

# Transfer workshop materials if they exist
if [ -d "materials/notebooks" ]; then
    echo ""
    echo "Step 3: Transferring workshop materials..."
    scp -r materials/notebooks/*.Rmd ${RAMSES_USER}@${RAMSES_HOST}:~/brms-workshop/materials/ 2>/dev/null || echo "  No .Rmd files found"
fi

echo ""
echo "========================================="
echo "✅ Deployment complete!"
echo "========================================="
echo ""
echo "Next steps (run on RAMSES):"
echo ""
echo "1. SSH to RAMSES (login nodes available):"
echo "   ssh ${RAMSES_USER}@${RAMSES_HOST}"
echo "   (or ramses4.itcc.uni-koeln.de)"
echo ""
echo "2. Check your default SLURM account:"
echo "   sacctmgr show assoc -n user=\$USER format=Account"
echo ""
echo "3. Pull the Docker container (takes ~10 minutes, only once):"
echo "   cd ~/brms-workshop/scripts"
echo "   bash pull_container_ramses.sh"
echo ""
echo "4. Test the container:"
echo "   sbatch test_apptainer.sh"
echo ""
echo "5. Check test results:"
echo "   squeue -u \$USER          # Check if job is running"
echo "   cat brms_test_*.out      # View results after completion"
echo ""
echo "Note: Always submit jobs via 'sbatch', do NOT run on login nodes"
echo ""
