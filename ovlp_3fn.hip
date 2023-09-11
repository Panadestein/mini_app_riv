#include <hip/hip_runtime.h>
#include <hipblas.h>
#include <hip/hip_runtime_api.h>

__global__ void hadamard_add(int nb, int n_aux, double *ovlp_3fn, double *psi_x_psi_x_aux, double *part_atoms, int k) {
    int i = blockIdx.i * blockDim.i + threadIdx.i;
    int j = blockIdx.j * blockDim.j + threadIdx.j;

    if (i < nb * nb && j < n_aux) {
        ovlp_3fn[i * n_aux + j] += psi_x_psi_x_aux[i * n_aux + j] * part_atoms[i * n_aux + k];
    }
}

void riv_compute_ovlp(int nb, int n_aux, int n_points, double *psi, double *aux, double *part_atoms, double *ovlp_3fn) {
    hipblasHandle_t handle;
    hipblasCreate(&handle);

    // Allocating device memory
    double *d_psi, *d_aux, *d_part_atoms, *d_ovlp_3fn, *d_psi_x_psi, *d_psi_x_psi_x_aux;
    hipMalloc((void **)&d_psi, nb * n_points * sizeof(double));
    hipMalloc((void **)&d_aux, n_aux * n_points * sizeof(double));
    hipMalloc((void **)&d_part_atoms, nb * nb * n_points * sizeof(double));
    hipMalloc((void **)&d_ovlp_3fn, nb * nb * n_aux * sizeof(double));
    hipMalloc((void **)&d_psi_x_psi, nb * nb * sizeof(double));
    hipMalloc((void **)&d_psi_x_psi_x_aux, nb * nb * n_aux * sizeof(double));

    // Copying data to device
    hipMemcpy(d_psi, psi, nb * n_points * sizeof(double), hipMemcpyHostToDevice);
    hipMemcpy(d_aux, aux, n_aux * n_points * sizeof(double), hipMemcpyHostToDevice);
    hipMemcpy(d_part_atoms, part_atoms, nb * nb * n_points * sizeof(double), hipMemcpyHostToDevice);
    hipMemcpy(d_ovlp_3fn, ovlp_3fn, nb * nb * n_aux * sizeof(double), hipMemcpyHostToDevice);

    // Constants for hipblas
    const double alpha = 1.0, beta = 0.0;

    for (int k = 0; k < n_points; ++k) {
        hipblasDger(handle, nb, nb, &alpha, d_psi + k * nb, 1, d_psi + k * nb, 1, d_psi_x_psi, nb);
        hipblasDger(handle, nb * nb, n_aux, &alpha, d_psi_x_psi, 1, d_aux + k * n_aux, 1, d_psi_x_psi_x_aux, nb * nb);

        // Launching the Hadamard addition kernel
        dim3 dimBlock(16, 16);
        dim3 dimGrid((nb * nb + 15) / 16, (n_aux + 15) / 16);
        hadamard_add<<<dimGrid, dimBlock>>>(nb, n_aux, d_ovlp_3fn, d_psi_x_psi_x_aux, d_part_atoms, k);
    }

    // Copying the result back to host
    hipMemcpy(ovlp_3fn, d_ovlp_3fn, nb * nb * n_aux * sizeof(double), hipMemcpyDeviceToHost);

    // Free device memory
    hipFree(d_psi);
    hipFree(d_aux);
    hipFree(d_part_atoms);
    hipFree(d_ovlp_3fn);
    hipFree(d_psi_x_psi);
    hipFree(d_psi_x_psi_x_aux);

    hipblasDestroy(handle);
}

int main() {
    // Initialize your variables, allocate host memory and populate them

    // Call the riv_compute_ovlp function

    return 0;
}
