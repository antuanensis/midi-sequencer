# Milestone Plan

## Milestone 1: Pure Engine

Definition: A 16-step clip can render deterministic MIDI output from pure Swift modules, with tests for locks, probability, transforms, and quantization.

- [x] Create repo docs and project memory.
- [x] Create SwiftPM package.
- [x] Implement initial MIDI event types.
- [x] Implement initial clip, step, lock, pitch behavior, theory, and transform logic.
- [x] Add initial tests.
- [x] Add project-level Codable models.
- [x] Add transform command metadata and project-state transform application.
- [x] Add LFO model and tests.
- [x] Add render-window playback API.
- [x] Add fixture projects.

## Milestone 2: Debug App

Definition: A user can run a standalone/debug app, edit a 16-step clip, press play, and send MIDI events.

- [ ] Create Xcode app target.
- [ ] Build SwiftUI clip grid.
- [ ] Build step and lock editor.
- [ ] Connect debug transport to engine.
- [ ] Add debug MIDI output.

## Milestone 3: AUv3 MIDI Processor

Definition: A host can load the plugin, start transport, and receive MIDI notes from the engine.

- [ ] Create AUv3 app extension target.
- [ ] Add minimal host transport sync.
- [ ] Bridge scheduled events to AU MIDI output.
- [ ] Validate in at least one host.

## Milestone 4: Persistence

Definition: Projects can be saved, loaded, and round-trip tested.

- [ ] Implement persistence module.
- [ ] Add project schema versioning.
- [ ] Add Codable round-trip tests.
- [ ] Add demo fixtures.
