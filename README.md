# RIV algorithm mini-app

This repository contains an HPC mini-app designed to study a part of the RI-V algorithm for approximating electronic integrals. The aim is to simplify comparisons with the HIP implementation, thereby enhancing the ease of analysis.

## Mathematical overview

Contrary to the convoluted logic commonly imposed by look-up tables in many quantum chemistry codes, the core mathematical computation in this segment is straightforward. The tensors $O_{\mu\nu}^P\$ can be constructed as:

$$
  O_{\mu\nu}^P = ((\psi_{\mu} \otimes \psi_{\mu}) \otimes \phi_{P}) \odot T_{\mu\nu P}
$$

That is, a series of tensor products followed by a Hadamard product. Below is a sample code snippet written in Julia:

```julia
  ovlp_3fn = zeros(size(ovlp_3fn))
  for k in 1:n_points
      psi_x_psi = psi[:, k] * psi[:, k]'
      ovlp_3fn .+= (psi_x_psi[:] * aux[:, k]') .* part_atoms[:, :, k]
  end
```

## Nix flakes

This project employs Nix Flakes to establish a reproducible environment. To initiate a development shell, navigate to the repository's root directory and execute the following command:

```nix
nix develop .#devShell.x86_64-linux
```
