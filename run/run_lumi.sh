#!/bin/bash
# ----- SLURM JOB SUBMIT SCRIPT -----
#SBATCH --exclusive
#SBATCH --error=slurm.%J.err
#SBATCH --output=slurm.%J.out


# -- job info --

#SBATCH --job-name=RTest
#SBATCH --time=00:30:00
#
# -- number of nodes and CPU
#
#sbatch --reservation=Nomad
#SBATCH --partition=standard-g
#SBATCH --account=project_465000538
#SBATCH --nodes=1               # Total number of nodes 
#SBATCH --ntasks-per-node=8     # 8 MPI ranks per node
#SBATCH --gpus-per-node=8       # Allocate one gpu per MPI rank
#SBATCH --gpus-per-task=1

EXE="/pfs/lustrep3/scratch/project_465000538/aims-team/mini_app_riv/build/riv_tens"
OUT="riv_tens.out"

# Modules for HIP
module load LUMI/22.12 buildtools/22.12 CMake/3.25.2
module load PrgEnv-cray
module load craype-accel-amd-gfx90a
module load cray-libsci
module load rocm

# Environment variables
export UCX_LOG_LEVEL=error

echo ' --------------------------------------------------------------'
echo ' |        --- RUNNING JOB ---                                 |'
echo ' --------------------------------------------------------------'

# print some informations
nnodes=${SLURM_NNODES}
nranks=${SLURM_NTASKS}
nthreads_per_rank=${SLURM_CPUS_PER_TASK}
nthreads=$((${nthreads_per_rank} * ${nranks}))
echo "JOB-config:   nodes=${nnodes} threads/rank=${nthreads_per_rank}"
echo "JOB-total:    nodes=${nnodes} ranks=${nranks} threads=${nthreads}"

# run the program
srun ${EXE} >& $OUT

echo ' --------------------------------------------------------------'
echo ' |        --- DONE ---                                        |'
echo ' --------------------------------------------------------------'

exit 0

