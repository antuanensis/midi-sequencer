# Architecture Overview

## Current Architecture

The repository starts as a Swift Package with pure engine modules and XCTest coverage. AUv3 and SwiftUI targets are documented but intentionally not scaffolded yet.

## Planned Architecture

```text
SwiftUI Debug App -> Project State -> SequencerCore -> MIDI Events
AUv3 Plugin ------> Host Sync -----> SequencerCore -> AU MIDI Output
Tests ------------> Pure Modules
Persistence ------> Codable Project State
```

## Main Modules

- `MidiCore`: MIDI notes, channels, events, timing, seeded randomness.
- `LockEngine`: step locks and pitch behavior maps.
- `SequencerCore`: clips, steps, playback rendering.
- `TransformEngine`: duplicate, delete, transpose, octave shift, rotate, reverse, quantize.
- `TheoryEngine`: roots, scales, modes, quantization.
- `Persistence`: future Codable save/load boundary.
- `AUv3Plugin`: future host sync and MIDI output adapter.
- `AppUI`: future SwiftUI clip and lock editor.

## Data Flow

Project state owns tracks and clips. The sequencer resolves base steps plus sparse locks plus pitch behavior into scheduled MIDI events. AUv3 and UI layers consume or display these events but do not own sequencing rules.

## External Dependencies

Current implementation uses Swift, SwiftPM, and XCTest only. Apple frameworks will be added when app and AUv3 targets are introduced.

## Persistence

Core project models should remain Codable. Persistence should serialize explicit clip transforms and sparse overrides rather than expanded runtime output.

## Testing Approach

Pure modules must be tested with deterministic seeds and no AUv3 host. AUv3 integration will need adapter tests plus manual host QA.

## Open Architecture Questions

- Exact Xcode target layout for standalone app plus AUv3 extension.
- Whether clip transforms should be stored as a history, baked into clip data, or both.
- How far MVP LFOs go before becoming modulation overreach.
