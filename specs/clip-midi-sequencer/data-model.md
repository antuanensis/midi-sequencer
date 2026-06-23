# Clip MIDI Sequencer Data Model

## Requirements

- Store locks as sparse overrides, not full duplicated data.
- Keep clip transformations explicit and serializable.
- Make project files Codable.
- Keep timing deterministic for tests.

## MVP Entities

### Project

Contains tracks, clips, global scale defaults, and persistence metadata.

Current implementation: `SequencerProject` with schema version, id, name, tracks, clips, default scale, and transform history.

### Track

Owns a MIDI output channel and clip reference. MVP has one track.

Current implementation: `SequencerTrack` with id, name, MIDI channel, clip ids, active clip id, and mute state.

### Clip

Contains 16 steps, sparse step locks, pitch behavior map, and timing settings.

Current implementation also stores clip-level LFOs for deterministic CC and probability modulation.

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

Current note: `PitchBehaviorMap` encodes behaviors as a stable entry list rather than relying on JSON dictionary encoding for enum keys.

Transform history is represented by `ClipTransformCommand` cases for duplicate, delete, transpose, octave shift, rotate, reverse, and quantize. Command application rules are the next step.

Current delete semantics: deleting a clip removes it from project clips and from track clip references. If a track's active clip is deleted, the track falls back to the first remaining clip reference or `nil` if the track has no clips.
