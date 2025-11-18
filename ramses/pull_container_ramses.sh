#!/bin/bash
# Pull BRMS Docker container to RAMSES using Apptainer
# Run this ON RAMSES (after SSH)

set -e

echo "=========================================="
echo "BRMS Container Setup on RAMSES"
echo "=========================================="
echo ""
echo "System: $(hostname)"
echo "User: $USER"
echo "Date: $(date)"
echo ""

# Check if Apptainer is available
if ! command -v apptainer &> /dev/null; then
    echo "❌ ERROR: Apptainer not found"
    echo "Please contact HPC support: hpc-mgr@uni-koeln.de"
    exit 1
fi

echo "✅ Apptainer found: $(apptainer --version)"
echo ""

# Create containers directory
CONTAINER_DIR="$HOME/containers"
mkdir -p $CONTAINER_DIR
cd $CONTAINER_DIR

echo "Container directory: $CONTAINER_DIR"
echo ""

# Use Docker Hub as the default source
DOCKER_IMAGE="docker://jobschepens/brms-workshop:working"
OUTPUT_FILE="brms-workshop_working.sif"

echo "Pulling from: $DOCKER_IMAGE"
echo "Output file: $OUTPUT_FILE"
echo ""

# Check if file already exists
if [ -f "$OUTPUT_FILE" ]; then
    echo "⚠️  Warning: $OUTPUT_FILE already exists"
    echo "   Size: $(du -h $OUTPUT_FILE | cut -f1)"
    echo "   Modified: $(stat -c %y $OUTPUT_FILE 2>/dev/null || stat -f '%Sm' $OUTPUT_FILE)"
    echo ""
    read -p "Overwrite? (y/n) [n]: " overwrite
    if [[ ! $overwrite =~ ^[Yy]$ ]]; then
        echo "Keeping existing file. Exiting."
        exit 0
    fi
    echo "Removing old file..."
    rm $OUTPUT_FILE
fi

# Pull container
echo "=========================================="
echo "Pulling container (this may take 5-10 minutes)..."
echo "=========================================="
echo ""

start_time=$(date +%s)

apptainer pull $DOCKER_IMAGE

end_time=$(date +%s)
elapsed=$((end_time - start_time))
minutes=$((elapsed / 60))
seconds=$((elapsed % 60))

echo ""
echo "=========================================="
echo "✅ Container pulled successfully!"
echo "=========================================="
echo ""
echo "Time taken: ${minutes}m ${seconds}s"
echo "File: $CONTAINER_DIR/$OUTPUT_FILE"
echo "Size: $(du -h $OUTPUT_FILE | cut -f1)"
echo ""

# Test the container
echo "Testing container..."
echo "----------------------------------------"
apptainer exec $OUTPUT_FILE R --version
echo ""

# Check if BRMS is available
echo "Checking BRMS installation..."
echo "----------------------------------------"
apptainer exec $OUTPUT_FILE Rscript -e "cat('BRMS version:', as.character(packageVersion('brms')), '\n')" 2>/dev/null || echo "BRMS check completed"
echo ""

echo "========================================="
echo "Next Steps"
echo "========================================="
echo ""
echo "1. Check your SLURM account (for billing):"
echo "   sacctmgr show assoc -n user=\$USER format=Account"
echo ""
echo "2. Submit a test job:"
echo "   cd ~/brms-workshop/scripts"
echo "   sbatch test_apptainer.sh"
echo ""
echo "3. Monitor job status:"
echo "   squeue -u \$USER"
echo "   cat brms_test_*.out      # After job completes"
echo ""
echo "4. Run your analysis:"
echo "   Create a SLURM job script with:"
echo "   - #SBATCH --account=<youraccount>"
echo "   - #SBATCH --mem=16gb (adjust as needed)"
echo "   - apptainer exec $CONTAINER_DIR/$OUTPUT_FILE Rscript your_analysis.R"
echo ""
echo "Tip: Use /scratch/\$USER/ for temporary files (better I/O)"
echo ""
