{
  description = "An HIP development flake";
  nixConfig.bash-prompt = ''\[\033[1;31m\][\[\033[0m\]\[\033[1;37m\]dev .\[\033[0m\]\[\033[1;34m\] $(basename \$$PWD)\[\033[0m\]\[\033[1;31m\]]\[\033[0m\] '';

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      findent = pkgs.stdenv.mkDerivation rec {
        pname = "findent";
        version = "4.2.6";
        
        src = pkgs.fetchurl {
          url = "mirror://sourceforge/findent/${pname}-${version}.tar.gz";
          sha512 = "1d97005a6f414a1876dd2140922125b7e399fc7b03afaea0b2fe6dfd7eb6baeb3bf16d3ae7b259e3c9a613a889f2759393c1ed5f98e5bda8ee6ea3ddd5e713c0";
        };

        nativeBuildInputs = [ pkgs.gnumake pkgs.gcc ];
        buildInputs = [ pkgs.flex pkgs.bison ]; 

        configureFlags = [ "--prefix=${placeholder "out"}" ];
        
        meta = with pkgs.lib; {
          description = "A Fortran indenter";
        };
      };
    in
      {
        devShell.x86_64-linux = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Compilers
            gcc
            gfortran
            # HIP and ROCm
            hip
            hipblas
            rocm-device-libs
            # BLAS/ScaLAPACK
            lapack-reference
            scalapack
            # Utils
            cmake
            findent
            # Profilers
            valgrind
            linuxKernel.packages.linux_6_4.perf
            # Python packages
            fortls
          ];
        };
      };
}
