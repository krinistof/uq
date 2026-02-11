# UniQue Development Plan

## 1. Client Library Enhancements

### Port Logging Infrastructure
Migrate the logging capability from the `dt` frontend to the `uq` client library.
- [ ] Implement `UqLogger` class in `client/src/logger.ts`.
- [ ] Support `client_logs` topic for remote telemetry.
- [ ] Integrate global error handlers (`window.onerror`, `unhandledrejection`).

## 2. Example Application: Secure Card Game
A proof-of-concept, which demonstrates `uq`'s capabilities for peer-to-peer state synchronization without a central game server logic.

### Core Concepts
- **Deck State**: Cryptographically shuffled/committed deck (Mental Poker or simplified shared state).
- **Player Hand**: Private state, revealed only upon play.
- **Table State**: Public board state synced via `uq` events.

### Actions
- **Draw**: A player claims a card from the deck.
    - *Event*: `DrawCard(PlayerPK, EncryptedCard)`
- **Pass**: A player transfers a card to another player.
    - *Event*: `PassCard(FromPK, ToPK, EncryptedCard, Signature)`
    - Requires targeted encryption (ECDH shared secret derived from `ToPK`).

## 3. Infrastructure & Testing

### Testing
- [ ] **Binary ConnectRPC Tests:** Add tests for binary connectrpc.
- [ ] **Regression Benchmarking:** Implement regression benchmarking to prevent merging slower implementations. Compare timed debug logs of all tests on both commits (PR vs Base).

## 4. Session Initialization & Cold Storage
Create a standalone Rust binary (`bin/session_init`) to bootstrap a secure session.

### Core Responsibilities
1.  **Key Generation**:
    - Generate N user identity keypairs (Ed25519).
    - Generate 1 shared "Topic Key" (for p2p encryption, unknown to server).
2.  **Persistence (Public)**:
    - Seed the runtime SQLite database with the User Public Keys (Whitelist).
    - Publish an initial unencrypted `Whitelist` event to the public/common topic.
3.  **Artifact Generation (Private)**:
    - Render `drafts/passport_demo.html` using `askama`.
    - Map struct fields for every variable text of the template.
    - **I18n Support**:
        - Abstract hardcoded strings ("READ MODE", "ROTATE CARD") into translation files.
        - Inject translated strings into the template based on lang settings.
4.  **Output**:
    - Write `session_[timestamp].html` for manual "Print to PDF" (Chrome).
    - **Security**: Private keys are *only* in the HTML/PDF, never saved to disk/DB.
