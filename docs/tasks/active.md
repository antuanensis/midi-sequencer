# Active Tasks

## Current Focus

Milestone 1: finish the deterministic pure MIDI sequencer engine for one 16-step clip before building UI or AUv3 integration.

This focus follows the original project rule: the sequencer must be testable without launching an AUv3 host. The fastest route to the product vision is a small engine that can prove clip playback, locks, transforms, scale behavior, pitch behavior, and modest LFO behavior with repeatable tests.

## Implementation Stream

1. Stabilize engine data and serialization.
2. Complete deterministic clip operations and modulation primitives.
3. Add fixtures that represent real musical use cases.
4. Build the standalone/debug app on top of the tested engine.
5. Connect AUv3 host sync and MIDI output only after the engine can stand alone.

## In Progress

- [x] Bootstrap repo docs and project memory.
  - Description: Added repo-specific agent instructions, project docs, specs, ADRs, devlog, task tracking, and testing notes.
  - Why: The project is intended to be serious and multi-session. Durable memory prevents drift into disconnected UI, AUv3, and engine work.

- [x] Create pure SwiftPM engine modules.
  - Description: Created initial `MidiCore`, `LockEngine`, `TheoryEngine`, `SequencerCore`, and `TransformEngine` modules.
  - Why: The vision depends on a reusable engine that can serve both the standalone app and AUv3 plugin without host-specific code leaking into sequencing logic.

- [x] Add initial deterministic engine tests.
  - Description: Added XCTest coverage for playback, sparse locks, probability, pitch behavior, transforms, and quantization.
  - Why: Deterministic tests are the guardrail for practical clip manipulation. They keep the app from becoming a flashy interface over untrusted timing behavior.

- [ ] Add project-level Codable models.
  - Description: Introduce `Project`, `Track`, clip collection, global scale defaults, and schema/version metadata around the existing clip engine.
  - Why: The original idea requires project files to be Codable and clips to be duplicated, deleted, transformed, and persisted. This is the smallest next step that turns a single clip engine into an app-shaped data model.
  - Stream position: Do this before persistence, fixtures, UI, or AUv3 so every later layer edits the same canonical state.
  - Tests required: Codable round-trip tests for project, track, clip, locks, pitch behaviors, and transform metadata.

## Next Safe Task

Add project-level Codable types for project, track, clip collection, and transform metadata, then test JSON round-tripping.

## Blocked / Deferred

- [ ] Standalone/debug SwiftUI app target.
  - Description: Build the iPad debug editor after project state and fixtures exist.
  - Why deferred: The vision calls for a tactile editor, but building UI before the data model settles risks rework and encourages unfinished subsystems.

- [ ] AUv3 host sync integration.
  - Description: Translate host tempo, transport, and beat windows into engine render requests.
  - Why deferred: AUv3 should be a thin adapter. Starting here too early would make host behavior the center of the architecture instead of the tested engine.

- [ ] AUv3 MIDI output bridge.
  - Description: Convert scheduled engine events into AU MIDI output events.
  - Why deferred: MIDI output needs stable engine event semantics first, especially CC-before-note ordering and deterministic probability.
