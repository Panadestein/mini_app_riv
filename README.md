# RIV algorithm mini-app

This repository contains an HPC mini-app designed to study a part of the RI-V algorithm for approximating electronic integrals. The aim is to simplify comparisons with the HIP implementation, thereby enhancing the ease of analysis.

## Mathematical overview

The RI-V approximation can be used to reduce the computational cost of the four center electronic integrals. In this formalism, the more expensive part are the computation of the integrals:

$$
  O_{\mu\nu}^P = \int \frac{\psi_{\mu}(\mathbf{r})\psi_{\nu}(\mathbf{r})\phi_{P}(\mathbf{r}')}{|\mathbf{r}-\mathbf{r}'|}d\mathbf{r}d\mathbf{r}'
$$

Contrary to the convoluted logic commonly imposed by look-up tables in many quantum chemistry codes, the core mathematical computation in this segment is straightforward. We leave aside the details of the computation of the integral over $\mathbf{r}'$ with the Coulomb kernel, which yields the matrices $\Omega_P(\mathbf{r})$. The tensors $O_{\mu\nu}^P\$ then can be constructed as:

$$
  O_{\mu\nu}^P(k) = \psi_{\mu}(k) * \psi_{\nu}(k) * \Omega_P(k) * T_{\mu\nu P}(k)
$$

or in tensor form for every `k`:

$$
  \mathcal{O} = (\boldsymbol{\psi} \otimes \boldsymbol{\psi} \otimes \mathbf{\Omega}) \odot \mathcal{T}
$$

In this formulation, a sequence of tensor products culminates in a Hadamard product, with the integration weights being incorporated into the partition matrix $T_{\mu\nu P}$​. Below is a sample code snippet written in Julia to illustrate this approach.

```julia
  ovlp_3fn = zeros(size(ovlp_3fn))
  for k in 1:n_points
      psi_x_psi = psi[:, k] * psi[:, k]'
      ovlp_3fn .+= (psi_x_psi[:] * aux[:, k]') .* part_atoms[:, :, k]
  end
```

Here we loop through the quadrature points `k`, so the input arrays have an additional dimension.

## Nix flakes

This project employs Nix Flakes to establish a reproducible environment. To initiate a development shell, navigate to the repository's root directory and execute the following command:

```nix
nix develop .#devShell.x86_64-linux
```
