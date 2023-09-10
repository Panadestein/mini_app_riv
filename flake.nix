{
  description = "An HIP development flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = with pkgs; [
        # Compilers
        gcc
        gfortran
        hip
        # Libraries
        hipblas
        openblas
        scalapack
        # Utils
        cmake
        # Profilers
        valgrind
        linuxKernel.packages.linux_6_4.perf
      ];
    };
  };
}
