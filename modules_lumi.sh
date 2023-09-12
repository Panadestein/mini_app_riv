#!/bin/bash

# Modules for HIP
module load LUMI/22.12 buildtools/22.12 CMake/3.25.2
module load PrgEnv-cray
module load craype-accel-amd-gfx90a
module load cray-libsci
module use /pfs/lustrep2/projappl/project_462000125/samantao-public/mymodules
ml rocm/5.5.3
