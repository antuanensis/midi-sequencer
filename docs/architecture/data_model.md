# Data Model

The MVP data model is value-type and Codable-oriented:

- Project: scenes, tracks, clips, global theory settings.
- Track: MIDI channel, clip references, mute/solo later.
- Clip: 16 steps, sparse step locks, pitch behavior map, transform metadata.
- Step: base note, velocity, gate length, probability, octave, CC values.
- StepLock: optional sparse overrides for step fields.
- PitchBehaviorMap: pitch or pitch-class keyed MIDI behavior overrides.
- ClipLFO: beat-clocked deterministic modulation for MIDI-safe destinations.

Locks must remain sparse. Runtime-resolved steps are derived data and should not be persisted as duplicated step content.

Current implementation:

- `SequencerProject`: schema version, id, name, tracks, clips, default scale, transform history.
- `SequencerTrack`: id, name, MIDI channel, clip ids, active clip id, mute state.
- `ClipTransformCommand`: serializable duplicate, delete, transpose, octave shift, rotate, reverse, and quantize commands.
- `PitchBehaviorMap`: encodes to JSON as a stable list of target/behavior entries.
- `ClipLFO`: sine, triangle, or square modulation targeting CC values or probability.

Project transform application lives in `TransformEngine`. Successful commands update project state and append to transform history; failed commands leave history unchanged. Deleting a clip removes track references and clears active clip state when no fallback clip exists.
