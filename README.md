# UniQue (uq)

UniQue is a standalone identity and protocol library.

## Components

*   **proto/**: Protocol Buffer definitions (`uq.v1`).
*   **client/**: TypeScript client library.
*   **server/**: Rust server library (Axum + ConnectRPC).

## Development

This project uses **Nix Flakes** for development.

```bash
nix develop
```

### Build

**Server:**
```bash
cd server
cargo build
```

**Client:**
```bash
cd client
npm install
npm run generate
npm run build
```
