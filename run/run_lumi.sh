#!/bin/bash
#SBATCH --exclusive
#SBATCH --error=slurm.%J.err
#SBATCH --output=slurm.%J.out
#SBATCH --job-name=miniapp_run
#SBATCH --time=00:30:00
#sbatch --reservation=Nomad
#SBATCH --partition=standard-g
#SBATCH --account=project_465000538
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --gpus-per-task=1

# Modules for HIP
module load LUMI/22.12 buildtools/22.12 CMake/3.25.2
module load PrgEnv-cray
module load craype-accel-amd-gfx90a
module load cray-libsci
module use /pfs/lustrep2/projappl/project_462000125/samantao-public/mymodules
ml rocm/5.5.3

# Environment variables
export UCX_LOG_LEVEL=error
EXE="/pfs/lustrep3/scratch/project_465000538/aims-team/mini_app_riv/build/riv_tens"
OUT="riv_tens.out"

echo ' --------------------------------------------------------------'
echo ' |        --- RUNNING JOB ---                                 |'
echo ' --------------------------------------------------------------'

# Job configuration
nnodes=${SLURM_NNODES}
nranks=${SLURM_NTASKS}
nthreads_per_rank=${SLURM_CPUS_PER_TASK}
nthreads=$((nthreads_per_rank * nranks))
echo "JOB-config: nodes=${nnodes} threads/rank=${nthreads_per_rank}"
echo "JOB-total: nodes=${nnodes} ranks=${nranks} threads=${nthreads}"

# Run the program
srun ${EXE} >& $OUT

echo ' --------------------------------------------------------------'
echo ' |        --- DONE ---                                        |'
echo ' --------------------------------------------------------------'

