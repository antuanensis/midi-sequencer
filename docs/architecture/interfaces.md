# Interfaces

## Pure Engine

- Input: `MIDIClip`, loop count, seed, channel.
- Output: ordered `ScheduledMIDIEvent` values.

## Future AUv3 Adapter

- Input: host tempo, transport, beat range, plugin state.
- Output: AU MIDI event blocks.

## Future UI Adapter

- Input: user gestures and project state.
- Output: edits to Codable project state and preview transport commands.
