# MIDI Engine Spec

## Purpose

Render clip state into deterministic scheduled MIDI events.

## Timing

MVP clips use 16 steps. The initial engine uses beat-based timing with `beatsPerStep = 0.25`, producing a 4-beat loop.

## Event Rules

- Emit locked CC values before note-on at the same beat.
- Emit note-off at `noteOnBeat + gateLengthBeats`.
- Clamp MIDI note and seven-bit values to `0...127`.
- Keep output channel in `1...16`.
- Use seeded randomness for probability.

## Step Resolution

1. Start with base step.
2. Apply sparse step lock.
3. Apply octave offset.
4. Resolve pitch behavior.
5. Apply probability.
6. Emit CC, note-on, note-off, and harmony events.

## Host Sync

AUv3 host sync is a later adapter. It should translate tempo, transport, and beat ranges into engine render windows without moving sequencing rules into the plugin.

Current implementation: the engine can render scheduled MIDI events for a requested beat range. Windowed output matches full-loop rendering filtered to the same range, including note-off events that fall inside the window for notes triggered before the window.

## LFO Direction

LFOs should be deterministic, beat-clocked, and initially limited to MIDI-safe destinations such as CC value modulation or probability modulation. Avoid free-running hidden state in core tests.

Current implementation:

- Shapes: sine, triangle, square.
- Clocking: value is derived from beat, rate, and phase offset.
- Destinations: MIDI CC values and probability modulation.
- Scope: LFO values are evaluated during deterministic engine rendering.
