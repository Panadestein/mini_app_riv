{
  description = "An HIP development flake";
  nixConfig.bash-prompt = ''\033[1;31m[\033[0m\033[1;37mdev .\033[0m\033[1;34m $(basename \$$PWD)\033[0m\033[1;31m]\033[0m '';

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
