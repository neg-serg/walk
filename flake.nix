{
  description = "walk - TUI file navigator (Go)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
        version = if self ? rev then self.rev else "dev";
      in {
        packages = rec {
          walk = pkgs.buildGoModule {
            pname = "walk";
            inherit version;
            src = ./.;
            vendorHash = "sha256-a66vA6eFzckxBpVtHaX0PBtulTBPbh7c6HY3dIZAym8=";
            # Build the main package in the repo root.
            subPackages = [ "." ];
            meta = with lib; {
              description = "walk - TUI file navigator";
              homepage = "https://github.com/neg/walk";
              license = licenses.mit;
              mainProgram = "walk";
              platforms = platforms.linux ++ platforms.darwin;
            };
          };
          default = walk;
        };

        apps = {
          walk = {
            type = "app";
            program = "${self.packages.${system}.walk}/bin/walk";
          };
          default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/walk";
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.go
            pkgs.gopls
            pkgs.delve
          ];
        };

        checks.build = self.packages.${system}.default;
      }
    );
}
