# System Context

MidiSequencer sits between a host transport or standalone debug transport and MIDI destinations.

- Input: host tempo, beat position, transport state, user-edited project state.
- Core processing: deterministic clip playback, locks, transforms, scale quantization, pitch behavior.
- Output: MIDI note and CC events through AUv3 MIDI output or standalone debug MIDI output.

The core engine must not depend on AUv3, SwiftUI, or Core MIDI runtime objects.
