{
  description = "A basic Nix flake providing development shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-stable.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-v2505.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-v2411.url = "github:NixOS/nixpkgs/nixos-24.11";
    nur = {
      url = "github:nix-community/NUR";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-unstable,
      nixpkgs-v2505,
      nixpkgs-v2411,
      nur,
      ...
    }@inputs:
    let
      pkg-settings = rec {
        allowed-unfree-packages =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "cudnn"
            "libcublas"
          ];
        allowed-insecure-packages = [
          "electron-11.5.0"
          "openssl-1.1.1w"
        ];
      };

      eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg-settings.allowed-unfree-packages;
            config.permittedInsecurePackages = pkg-settings.allowed-insecure-packages;
            overlays = [
              nur.overlays.default
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfreePredicate = pkg-settings.allowed-unfree-packages;
                  config.permittedInsecurePackages = pkg-settings.allowed-insecure-packages;
                  overlays = [ nur.overlays.default ];
                };
              })
              (final: prev: {
                v2505 = import nixpkgs-v2505 {
                  inherit system;
                  config.allowUnfreePredicate = pkg-settings.allowed-unfree-packages;
                  config.permittedInsecurePackages = pkg-settings.allowed-insecure-packages;
                  overlays = [ nur.overlays.default ];
                };
              })
              (final: prev: {
                v2411 = import nixpkgs-v2411 {
                  inherit system;
                  config.allowUnfreePredicate = pkg-settings.allowed-unfree-packages;
                  config.permittedInsecurePackages = pkg-settings.allowed-insecure-packages;
                  overlays = [ nur.overlays.default ];
                };
              })
            ];
          };
        in
        {
          default = pkgs.mkShellNoCC {
            name = "thegibook-dev";
            hardeningDisable = [ "fortify" ];
            packages = with pkgs; [
              texliveFull
              pandoc
              typst
              nodejs
            ];
            shellHook = ''
              echo "╔════════════════════════════════════════════════════════════╗"
              echo "║  TheGIBook Development Environment                         ║"
              echo "║  全局光照技术：从离线到实时渲染                            ║"
              echo "╚════════════════════════════════════════════════════════════╝"
              echo ""

              # Helper functions
              build_pdf() {
                echo "Building theGIbook.pdf..."
                latexmk -xelatex -bibtex theGIbook.tex
                echo "Done: theGIbook.pdf"
              }

              clean_latex() {
                echo "Cleaning LaTeX files..."
                rm -f *.aux *.log *.out *.toc *.lof *.lot
                rm -f *.bbl *.blg *.brf
                rm -f *.idx *.ilg *.ind *.synctex.gz
                rm -f *.mtc* *.maf
                rm -rf *.fls *.fdb_latexmk *.xdv
                echo "Clean complete"
              }

              echo "Available commands:"
              echo "  build_pdf        - Build the complete PDF"
              echo "  clean_latex      - Clean generated files"
              echo "  python main.py <build|clean> - Run the Python script directly"
            '';
          };
        }
      );

    in
    {
      devShells = eachSystem;
    };
}
