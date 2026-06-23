# Clip MIDI Sequencer Product Spec

## Status

Active for Milestone 1.

## Product Direction

Build a fast, tactile MIDI clip laboratory for iPad: Ableton-style clip usefulness, Elektron-style locks, and software-native transformation tools.

## MVP Goal

A user can load or run the debug app, create a 16-step MIDI clip, apply step locks, press play, and receive deterministic MIDI output from the sequencer engine. AUv3 host sync can be stubbed or minimal at first.

## Core MVP

- Minimal AUv3 MIDI processor.
- Host tempo and transport sync.
- One track with one looping MIDI clip.
- 16-step clip model.
- MIDI note output from the clip.
- Step locks for note, velocity, gate length, probability, octave, and MIDI CC values.
- Clip operations: duplicate, delete, transpose, octave shift, rotate, reverse.
- Scale support: root note, scale/mode, quantize notes to scale.
- Simple SwiftUI editor for standalone/debug app.
- Unit tests for playback, locks, probability, transpose, octave shift, and quantization.
- LFO capabilities, kept deterministic and modest in MVP.

## Avoid In MVP

- AI composition.
- Clip genetics.
- Complex MPE.
- Advanced voice leading.
- Audio DSP.
- Decorative UI.
- Overcomplicated modulation.
- Generative phrase compiler.

## Success Criteria

- Pure engine tests pass without AUv3 host launch.
- A 16-step clip renders predictable MIDI events.
- Step locks and pitch behavior are sparse, explicit, Codable-friendly data.
- AUv3 layer is an adapter over the engine, not the home of sequencing rules.
