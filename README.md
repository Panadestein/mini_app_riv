# RIV algorithm mini-app

A mini-app to isolate a part of the RIV algorithm and facilitate the comparison with the HIP implementation. A Julia pseudocode is:

```julia
  ovlp_3fn = zeros(size(ovlpefn))
  for k in 1:n_points
      psi_x_psi = psi[:, k] * psi[:, k]'
      ovlp_3fn .+= (psi_x_psi[:] * aux[:, k]') .* part_atoms[:, :, k]
  end
```

## Nix flakes

This project uses `nix flakes` to ensure reproducibility. To enter a development shell, issue this command on the root directory of this repo:

```nix
nix develop .#devShell.x86_64-linux
```
