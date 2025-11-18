# Running BRMS on RAMSES HPC - Quick Start

## TL;DR - Fastest Path

```bash
# On your local machine
cd /c/GitHub/brms-ws
bash deploy_to_ramses.sh

# On RAMSES (after SSH)
cd ~/brms-workshop/scripts
bash pull_container_ramses.sh  # ~10 minutes
sbatch test_apptainer.sh        # Test it
cat brms_test_*.out             # Check results
```

## What's Available on RAMSES

✅ **Apptainer 1.4.3** - Run Docker containers on HPC  
✅ **R 4.4.1** - Latest R version  
✅ **RStudio Server** - For interactive sessions  
✅ **CmdStanR module** - Pre-built Stan support  

## Workflow: Apptainer Container

**Time:** ~10 minutes one-time setup  
**Reproducibility:** ⭐⭐⭐⭐⭐  
**Updates:** Pull new container when needed

**Pros:**
- All dependencies pre-installed (BRMS, Stan, tidyverse, etc.)
- Exact same environment as Docker/Binder/Codespaces
- Portable across systems
- Fast setup
- No local Docker-to-Singularity conversion needed

**How it works:**
1. Deploy scripts to RAMSES from your local machine
2. SSH to RAMSES
3. Use Apptainer to pull Docker container directly from Docker Hub
4. Run BRMS analyses

**Quick Start:**
```bash
# 1. Deploy to RAMSES (from local machine)
bash deploy_to_ramses.sh

# 2. SSH to RAMSES
ssh jschepen@ramses1.itcc.uni-koeln.de

# 3. Pull container (only once, ~10 minutes)
cd ~/brms-workshop/scripts
bash pull_container_ramses.sh

# 4. Test it
sbatch test_apptainer.sh

# 5. Run your analysis
apptainer exec ~/containers/brms-workshop_working.sif \
  Rscript ~/brms-workshop/my_analysis.R
```

---

## Running BRMS Models

### Example: Simple Linear Model

Create `~/brms-workshop/simple_model.R`:

```r
library(brms)
library(tidyverse)

# Set options
options(mc.cores = 8)

# Load data
data <- read_csv("~/brms-workshop/data/mydata.csv")

# Fit model
fit <- brm(
  outcome ~ predictor1 + predictor2 + (1|group),
  data = data,
  family = gaussian(),
  chains = 4,
  cores = 4,
  iter = 2000,
  seed = 123
)

# Save results
saveRDS(fit, "~/brms-workshop/results/fit.rds")
summary(fit)
```

### SLURM Job Script

Create `~/brms-workshop/run_model.sh`:

```bash
#!/bin/bash -l
#SBATCH --job-name=brms_model
#SBATCH --output=brms_%j.out
#SBATCH --error=brms_%j.err
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32gb
#SBATCH --account=<youraccount>

# BRMS Analysis with Apptainer Container
# Uses /scratch for temporary files (better I/O performance)

CONTAINER="$HOME/containers/brms-workshop_working.sif"

# Create work directory in /scratch
workdir=/scratch/${USER}/${SLURM_JOB_ID}
mkdir -p $workdir

# Copy input data to scratch
cp ~/brms-workshop/data/* $workdir/
cd $workdir

# Run analysis in container
apptainer exec \
  --bind $workdir:/workspace \
  --bind /scratch/$USER:/scratch \
  $CONTAINER \
  Rscript ~/brms-workshop/simple_model.R

# Copy results back
cd -
cp ${workdir}/*.rds ~/brms-workshop/results/
cp ${workdir}/*.pdf ~/brms-workshop/results/
```

**Submit:**
```bash
sbatch run_model.sh
```

---

## Common Tasks

### Check Job Status
```bash
squeue -u jschepen              # Running/pending jobs
squeue -j JOBID                 # Detailed status of specific job
sstat JOBID                     # Runtime information (running jobs)
sacct -j JOBID                  # Accounting info (finished jobs)
scontrol show job JOBID         # Detailed job info
seff JOBID                      # Efficiency of completed job
squeue --start -j JOBID         # Estimated start time
```

### View Results
```bash
cat brms_*.out                  # Standard output
cat brms_*.err                  # Errors/warnings
tail -f brms_*.out              # Follow output in real-time
```

### Cancel Jobs
```bash
scancel JOBID                   # Cancel specific job
scancel -u jschepen             # Cancel all your jobs
```

### Update Container
```bash
cd ~/containers
rm brms-workshop_working.sif
apptainer pull docker://jobschepens/brms-workshop:working
```

### Check Your Default Account
```bash
sacctmgr show assoc -n user=$USER format=Account
```

---

## Resource Guidelines

| Model Complexity | CPUs | Memory | Time | Example |
|------------------|------|--------|------|---------|
| Simple (< 1000 obs) | 4 | 8gb | 30min | Linear regression |
| Medium (< 10k obs) | 8 | 16gb | 2hrs | Mixed models |
| Large (< 100k obs) | 16 | 32gb | 8hrs | Complex hierarchical |
| Very Large | 32 | 64gb | 24hrs | Spatial/temporal models |

**RAMSES Partitions:**
- Jobs automatically routed to `smp` partition (default)
- For large memory (>750GB): use `bigsmp` partition
- No need to specify partition for typical BRMS jobs

**Important:**
- Specify `--account=<youraccount>` for billing
- Default account: run `sacctmgr show assoc -n user=$USER format=Account`
- Use `/scratch/$USER/` for temporary files (better I/O performance)

**Adjust based on:**
- Number of chains (multiply CPUs)
- Number of iterations
- Model complexity
- Data size

---

## Troubleshooting

### Container not found
```bash
cd ~/containers
bash ~/brms-workshop/scripts/pull_container_ramses.sh
```

### Job fails immediately
```bash
cat brms_*.err              # Check error messages
scontrol show job JOBID     # Check job details
```

### Job pending for long time
```bash
squeue --start -j JOBID     # Check estimated start time
# Consider reducing resources if waiting too long
```

### CmdStan compilation errors
- Increase memory: `#SBATCH --mem=16gb`
- Increase time: `#SBATCH --time=02:00:00`

### Model takes too long
- Reduce iterations: `iter = 1000`
- Reduce warmup: `warmup = 500`
- Reduce chains: `chains = 2`
- Use more cores: `#SBATCH --cpus-per-task=16`

### Out of memory errors
- Check actual usage: `seff JOBID` (after job completes)
- Increase memory allocation: `#SBATCH --mem=64gb`
- Use `/scratch` for temporary files

---

## File Organization

```
~/brms-workshop/
├── scripts/
│   ├── pull_container_ramses.sh  # Pull container from Docker Hub
│   ├── test_apptainer.sh         # Test container
│   ├── run_model.sh              # Your job scripts
│   └── *.R                       # Your R scripts
├── data/                         # Input data
├── results/                      # Model outputs
└── materials/                    # Workshop notebooks
```

---

## Advanced Features

### Email Notifications

Add to your SLURM script to receive email updates:

```bash
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=username@uni-koeln.de
```

**Note:** Only UoC addresses (`@uni-koeln.de` or `@smail.uni-koeln.de`) are allowed.

### Using /scratch for Better Performance

The `/scratch` directory provides better I/O performance than home directory:

```bash
# In your SLURM script
workdir=/scratch/${USER}/${SLURM_JOB_ID}
mkdir -p $workdir

# Copy data
cp ~/brms-workshop/data/* $workdir/
cd $workdir

# Run analysis
apptainer exec $CONTAINER Rscript analysis.R

# Copy results back
cp results/* ~/brms-workshop/results/
```

### Login Nodes

Submit jobs from login nodes:
- `ramses1.itcc.uni-koeln.de`
- `ramses4.itcc.uni-koeln.de`

Do NOT run computations directly on login nodes - always use `sbatch` or `salloc`.

---

## Getting Help

**RAMSES Support:**
- Technical: hpc-mgr@uni-koeln.de
- Scientific: wiss-anwendung@uni-koeln.de
- Documentation: https://gitlab.git.nrw/uzk-itcc-hpc/itcc-hpc-ramses/-/wikis/home

**BRMS Resources:**
- Documentation: https://paul-buerkner.github.io/brms/
- Forum: https://discourse.mc-stan.org/
- GitHub: https://github.com/paul-buerkner/brms

---

*Last Updated: November 18, 2025*
*RAMSES Cluster: Apptainer 1.4.3, R 4.4.1*
