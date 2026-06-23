# Data Model

The MVP data model is value-type and Codable-oriented:

- Project: scenes, tracks, clips, global theory settings.
- Track: MIDI channel, clip references, mute/solo later.
- Clip: 16 steps, sparse step locks, pitch behavior map, transform metadata.
- Step: base note, velocity, gate length, probability, octave, CC values.
- StepLock: optional sparse overrides for step fields.
- PitchBehaviorMap: pitch or pitch-class keyed MIDI behavior overrides.

Locks must remain sparse. Runtime-resolved steps are derived data and should not be persisted as duplicated step content.
