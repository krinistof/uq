# Developer Guide for AI Agents

This repository contains the **UniQue** protocol implementation, featuring a Rust server and a TypeScript client library.

## Critical Instructions for Agents

- **Environment**: This project uses **Nix Flakes** to manage development dependencies.

## Project Structure
- `server/`: Rust server application (Core Logic, Storage, Crypto).
- `client/`: TypeScript client library.
- `proto/`: Protocol Buffer definitions.
- `flake.nix`: Nix environment definition.

## Development Environment (Nix)
Ensure you are running inside the Nix shell. Check `flake.nix` for supported tools.

## Server (Rust)

### Commands
Run these commands from the `server/` directory. All standard rust tools are present.

- **Build**: `cargo build`
- **Test**: `cargo test`
- **Lint/Format**: `cargo fmt` and `cargo clippy`

### Code Style & Conventions
- **Style**: Standard Rust style.
- **Linting**: Enforced by git hooks and CI.

## Client (TypeScript)

### Commands
Run these commands from the `client/` directory.

- **Install**: `npm install`
- **Generate Types**: `npm run generate` (Generates protobuf code)
- **Build**: `npm run build`
- **Lint**: `npm run lint`

### Code Style & Conventions
- **Framework**: Library (no UI framework).
- **Build Tool**: `esbuild` / `tsc`.

## Protocol Buffers
Definitions are located in `proto/`. When modifying `.proto` files, remember to run `npm run generate` in the `client/` directory to update the TypeScript definitions.
