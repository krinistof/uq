{
  description = "UniQue (uq) Repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        commonInputs = with pkgs; [
          # Proto
          buf
          protobuf

          # Tools
          sqlite
        ];
        
        rustInputs = with pkgs; [
          rustToolchain
          pkg-config
          openssl
        ] ++ commonInputs;

        nodeInputs = with pkgs; [
          nodejs_22
          typescript
          esbuild
          biome
        ] ++ commonInputs;

        checkScript = pkgs.writeShellApplication {
          name = "check";
          runtimeInputs = rustInputs ++ nodeInputs;
          text = ''
            # Colors
            GREEN='\033[0;32m'
            BLUE='\033[0;34m'
            NC='\033[0m'

            MODE="all"
            if [ "$#" -gt 0 ]; then
                MODE="$1"
            fi
            
            echo -e "''${BLUE}[UQ Check] Running in mode: $MODE''${NC}"

            # --- Client Checks ---
            if [ "$MODE" = "all" ] || [ "$MODE" = "lint" ]; then
                echo -e "''${BLUE}[UQ Client] Installing & Building...''${NC}"
                (cd client && npm install && npm run build)
            fi

            # --- Server Checks ---
            if [ "$MODE" = "all" ] || [ "$MODE" = "lint" ]; then
                 echo -e "''${BLUE}[UQ Server] Formatting & Linting...''${NC}"
                 (cd server && cargo fmt --all -- --check)
                 (cd server && cargo clippy -- -D warnings)
            fi

            if [ "$MODE" = "all" ]; then
                 echo -e "''${BLUE}[UQ Server] Building...''${NC}"
                 (cd server && cargo build)
                 
                 echo -e "''${BLUE}[UQ Server] Testing...''${NC}"
                 (cd server && cargo test)
            fi
            
            echo -e "''${GREEN}UQ Checks passed!''${NC}"
          '';
        };

        buildScript = pkgs.writeShellApplication {
          name = "build";
          runtimeInputs = rustInputs ++ nodeInputs;
          text = ''
            BLUE='\033[0;34m'
            NC='\033[0m'
            
            echo -e "''${BLUE}[UQ Client] Building...''${NC}"
            (cd client && npm install && npm run build)

            echo -e "''${BLUE}[UQ Server] Building...''${NC}"
            (cd server && cargo build)
          '';
        };

      in
      {
        apps = {
          default = flake-utils.lib.mkApp { drv = checkScript; };
          check = flake-utils.lib.mkApp { drv = checkScript; };
          build = flake-utils.lib.mkApp { drv = buildScript; };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = rustInputs ++ nodeInputs;

          shellHook = ''
            export PATH=$PWD/node_modules/.bin:$PWD/client/node_modules/.bin:$PATH
          '';
        };
      }
    );
}
