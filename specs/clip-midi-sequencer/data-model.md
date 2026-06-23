# Clip MIDI Sequencer Data Model

## Requirements

- Store locks as sparse overrides, not full duplicated data.
- Keep clip transformations explicit and serializable.
- Make project files Codable.
- Keep timing deterministic for tests.

## MVP Entities

### Project

Contains tracks, clips, global scale defaults, and persistence metadata.

### Track

Owns a MIDI output channel and clip reference. MVP has one track.

### Clip

Contains 16 steps, sparse step locks, pitch behavior map, and timing settings.

### Step

Base step fields:

- note
- velocity
- gate length
- probability
- octave
- MIDI CC values

### Step Lock

Sparse optional overrides for a single step:

- note
- velocity
- gate length
- probability
- octave
- MIDI CC values

### Pitch Behavior Map

Rules keyed by exact pitch or pitch class. Supported behaviors:

- send MIDI CC values
- route to MIDI channel
- transpose by octaves
- reduce or multiply probability
- add harmony notes

Do not claim support for arbitrary synth parameter changes unless they are exposed through MIDI CC, MPE, channel routing, or AU parameters.

## Serialization Notes

Use Codable value types. If dictionary key types become awkward for JSON stability, introduce explicit arrays of key/value entries before shipping persistence.
