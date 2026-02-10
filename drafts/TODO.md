# UniQue Development Plan

## 1. Client Library Enhancements

### Port Logging Infrastructure
Migrate the logging capability from the `dt` frontend to the `uq` client library.
- [ ] Implement `UqLogger` class in `client/src/logger.ts`.
- [ ] Support `client_logs` topic for remote telemetry.
- [ ] Integrate global error handlers (`window.onerror`, `unhandledrejection`).

## 2. Example Application: Secure Card Game
A proof-of-concept to demonstrate `uq`'s capabilities for peer-to-peer state synchronization without a central game server logic.

### Core Concepts
- **Deck State**: Cryptographically shuffled/committed deck (Mental Poker or simplified shared state).
- **Player Hand**: Private state, revealed only upon play.
- **Table State**: Public board state synced via `uq` events.

### Actions
- **Draw**: A player claims a card from the deck.
    - *Event*: `DrawCard(PlayerPK, CardHash/EncryptedCard)`
- **Pass**: A player transfers a card to another player.
    - *Event*: `PassCard(FromPK, ToPK, EncryptedCard, Signature)`
    - Requires targeted encryption (ECDH shared secret derived from `ToPK`).

### Architecture
- **Topic**: One topic per Game Session.
- **Validation**: Clients validate the legality of moves (e.g., cannot draw from empty deck, cannot pass card you don't hold) by replaying the event log.
