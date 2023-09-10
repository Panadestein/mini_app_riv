# RIV algorithm mini-app

A mini-app to isolate a part of the RIV algorithm and facilitate the comparison with the HIP implementation. A Fortran-like pseudocode is:

```julia
  ovlpefn(nb*nb, n_aux) = 0.0d0
  do k = 1, n_points
     psi_x_psi(nb * nb) = dger(psi(1:nb, k), psi(1:nb, k)) ! Flattened outer product (possibly using lapack)
     psi_x_psi_x_aux(nb*nb, n_aux) = dger(psi_x_psi(1:nb*nb), aux(1:n_aux))
     do p = 1, n_aux
        do mn = 1, nb*nb
           ovlpefn(mn, p) = ovlpefn(mn, p) + psi_x_psi_x_aux(mn, p) * part_atoms(mn, p, k) ! Hadamard
        end do
     end do
  end do
```

## Nix flakes

This project uses `nix flakes` to ensure reproducibility. To enter a development shell, issue this command on the root directory of this repo:

```nix
nix develop .#devShell.x86_64-linux
```
