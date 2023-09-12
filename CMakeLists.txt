# Set the minimum required version of CMake
cmake_minimum_required(VERSION 3.22)

# Set compilers
set(CMAKE_Fortran_COMPILER "gfortran" CACHE STRING "Fortran compiler" FORCE)
set(CMAKE_HIP_FLAGS "${CMAKE_HIP_FLAGS} --rocm-path=/nix/store/5yw2kzv6jlsbshbizcklwlggihm3nzjh-rocm-runtime-5.4.3/")
set(CMAKE_HIP_FLAGS "${CMAKE_HIP_FLAGS} --rocm-device-lib-path=/nix/store/wlmk21f8mqmm84mqrkrxwd7x8layrh85-rocm-device-libs-5.4.4/amdgcn/bitcode/")
set(CMAKE_HIP_FLAGS "${CMAKE_HIP_FLAGS}" CACHE STRING "Arguments HIP" FORCE)

# Define the project name and the languages
project(mini_app_riv Fortran CXX)
enable_language(HIP)

# Find the BLAS and LAPACK libraries
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)
find_package(SCALAPACK REQUIRED)

# Find HIP runtime for AMD GPUs
find_package(HIP REQUIRED)
find_package(HIPBLAS REQUIRED)

# Set build type to Debug by default
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

# Set release flags
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
set(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE} -O3")

# Set compiler flags for debugging and warnings
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -Wall")
  set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -g -Wall")
endif()

# Add an executable target
add_executable(riv_tens ovlp_3fn.f90 lapack_interfaces.f90 kinds.f90 ovlp_3fn.hip)

# Link libraries
target_link_libraries(riv_tens ${BLAS_LIBRARIES} ${SCALAPACK_LIBRARIES} roc::hipblas)
