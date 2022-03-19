{
  description = "The Fortran IFS and Arpege Toolkit";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
  inputs.ecbuild = {
    url = "github:ecmwf/ecbuild";
    flake = false;
  };

  outputs = { self, nixpkgs, ecbuild }:
    let
      version = builtins.substring 0 8 self.lastModifiedDate;
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {
      overlay = final: prev: {
        fiat = with final; stdenv.mkDerivation rec {
          name = "fiat-${version}";
          src = self;
          nativeBuildInputs = [ cmake ecbuild gfortran perl openmpi ];
        };

      };

      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) fiat;
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.fiat);
    };
}
