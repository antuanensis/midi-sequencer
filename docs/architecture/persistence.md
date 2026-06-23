# Persistence

Persistence should serialize project state using Codable models from pure modules.

Rules:

- Store sparse step locks.
- Store pitch behavior maps explicitly.
- Store transforms in a serializable form when transform history matters.
- Do not persist host runtime state as project state.
- Add migration notes when model versions change.
