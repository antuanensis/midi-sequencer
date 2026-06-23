# Project Roadmap

## Milestone 1: Deterministic Pure Engine

- SwiftPM modules for MIDI, locks, sequencing, theory, and transforms.
- 16-step clip model.
- Deterministic playback rendering.
- Sparse step locks.
- Pitch behavior map.
- Unit tests for playback, locks, probability, transforms, and quantization.

## Milestone 2: Standalone Debug App

- SwiftUI clip grid and step editor.
- Play/stop transport backed by the pure engine.
- Simple MIDI output for local debugging.
- Fixture clips for demos and tests.

## Milestone 3: Minimal AUv3 MIDI Processor

- AUv3 app extension shell.
- Host tempo and transport sync.
- MIDI event output from engine events.
- Minimal parameter/state bridge.

## Milestone 4: Persistence and Workflow

- Codable project files.
- Save/load debug projects.
- Duplicate/delete clip workflow.
- Import/export fixture projects.

## Later

- Multi-track clips.
- macOS support.
- Deeper modulation and optional MPE.
- More scales and performance controls.
