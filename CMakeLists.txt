# Set the minimum required version of CMake
cmake_minimum_required(VERSION 3.22)

# Set compilers
set(CMAKE_Fortran_COMPILER "gfortran" CACHE STRING "Fortran compiler" FORCE)

# Define the project name and the languages
project(mini_app_riv Fortran CXX)
enable_language(HIP)

# Find the BLAS
find_package(BLAS REQUIRED)

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
target_link_libraries(riv_tens ${BLAS_LIBRARIES} roc::hipblas)
