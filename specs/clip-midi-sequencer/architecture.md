# Clip MIDI Sequencer Architecture

## Architecture Rule

Separate the sequencing engine from the AUv3 plugin. The sequencer must be testable without launching an AUv3 host.

## Planned Modules

- `MidiCore`: MIDI note, CC, channel, event, and timing types.
- `SequencerCore`: clips, steps, tracks, playback state.
- `LockEngine`: per-step and per-pitch locks.
- `TransformEngine`: transpose, octave shift, reverse, rotate, quantize.
- `TheoryEngine`: scales, modes, scale-degree mapping.
- `Persistence`: save/load project data.
- `AUv3Plugin`: host sync and MIDI output.
- `AppUI`: SwiftUI clip editor and step editor.

## Data Flow

```text
SwiftUI App UI -> Project State -> Sequencer Core -> MIDI Event Output
Project State -> Persistence
Project State -> Example Fixtures
Unit Tests -> Sequencer Core
Unit Tests -> Theory + Transform Logic
AUv3 Host -> AUv3Plugin -> Sequencer Core -> AU MIDI Output
```

## Boundary Rules

- Core modules do not import SwiftUI, AudioToolbox, AVFoundation, or Core MIDI runtime APIs.
- AUv3 code translates host timing into engine timing.
- UI edits project state; it does not schedule MIDI directly.
- Persistence saves project intent, not expanded runtime events.
