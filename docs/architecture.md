# UniQue (uq) Architecture

**UniQue** is a standalone identity and decentralized synchronization protocol. It provides the foundational layer for building offline-first, cryptographic local-first applications.

## Core Design

UniQue is designed around **Asymmetric Topics**:
*   **Topic**: Defined by a Public Key.
*   **Events**: Cryptographically signed payloads bound to a Topic.
*   **Sync**: A dumb, agnostic server syncs events between clients based on time ranges and topic interest.

For a reference implementation of an application built on `uq`, see [Democratic Tier (dt)](https://github.com/krinistof/dt).

## Data Model

### Events
Events are the atomic unit of state.
```protobuf
message Event {
  bytes topic_pk = 1;       // The channel/room identifier
  bytes author_pk = 2;      // The user identifier
  bytes signature = 3;      // Sig(payload + topic_pk)
  bytes payload = 4;        // Opaque application data
  int64 server_timestamp = 5;
}
```

### Verification
The protocol ensures:
1.  **Integrity**: `payload` has not been tampered with.
2.  **Authenticity**: `author_pk` actually signed the event.
3.  **Binding**: The event is explicitly intended for `topic_pk` (preventing replay attacks across topics).

## Synchronization Flow

1.  **Push**: Client signs an event and sends it to the Server.
2.  **Store**: Server verifies the signature. If valid, it stores it (append-only).
3.  **Pull**: Clients request "new events since timestamp `T`".
4.  **Apply**: Clients receive events, verify signatures locally, and apply them to their local state (Reducer pattern).
