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

- [x] Add project-level Codable models.
  - Description: Introduce `Project`, `Track`, clip collection, global scale defaults, and schema/version metadata around the existing clip engine.
  - Why: The original idea requires project files to be Codable and clips to be duplicated, deleted, transformed, and persisted. This is the smallest next step that turns a single clip engine into an app-shaped data model.
  - Stream position: Do this before persistence, fixtures, UI, or AUv3 so every later layer edits the same canonical state.
  - Tests required: Codable round-trip tests for project, track, clip, locks, pitch behaviors, and transform metadata.

- [x] Add explicit transform command metadata.
  - Description: Added serializable transform command cases for duplicate, delete, transpose, octave shift, rotate, reverse, and quantize.
  - Why: The original idea says transformations should be explicit and serializable; this records user intent instead of only baking anonymous edits into clip steps.

- [x] Define delete clip semantics for the one-clip MVP.
  - Description: Deleting a clip removes it from the project and from all track clip references. If the deleted clip was active, the track falls back to the first remaining clip or no active clip.
  - Why: Delete is part of the MVP clip operations, and this rule keeps project state explicit without inventing hidden replacement clips.

- [x] Add project-state transform application API.
  - Description: Added project-level application for duplicate, delete, transpose, octave shift, rotate, reverse, and quantize commands.
  - Why: UI, fixtures, persistence, and later AUv3 state handling now have one canonical transform path.

- [x] Add deterministic LFO model and tests.
  - Description: Added beat-clocked sine, triangle, and square LFOs with MIDI-safe destinations for CC values and probability modulation.
  - Why: LFOs are part of the original MVP, but this keeps them deterministic, testable, and modest instead of turning into an overbuilt modulation system.

- [x] Add render-window playback API.
  - Description: Added engine rendering for a beat range, matching full-loop rendering filtered to the same range.
  - Why: Debug app transport and AUv3 host callbacks need windowed playback instead of regenerating whole loops for every playback slice.

- [x] Add fixture projects and demo clips.
  - Description: Added a type-checked clip lab demo project that exercises locks, pitch behavior, transforms, quantization, LFOs, and windowed rendering.
  - Why: Fixtures give the future debug app realistic material and keep examples tied to executable tests.

## Next Safe Task

Create the smallest standalone/debug SwiftUI iPad app target that imports the SwiftPM engine and displays the demo clip with a renderable event log.

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
