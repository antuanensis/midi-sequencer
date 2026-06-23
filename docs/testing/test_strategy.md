# Test Strategy

## Test Philosophy

Core sequencing must be deterministic, fast, and testable without an AUv3 host. UI and AUv3 layers should be thin adapters over tested pure Swift modules.

## Required Test Types

- Unit tests for playback event ordering and timing.
- Unit tests for sparse step locks.
- Unit tests for probability with fixed seeds.
- Unit tests for pitch behavior maps.
- Unit tests for transpose, octave shift, rotate, reverse, and quantize.
- Future Codable round-trip tests for project files.
- Future adapter tests for host tempo and transport translation.

## Commands

```sh
swift test
```

## What Must Be Tested Before Completion

- A 16-step clip renders note-on and note-off events at expected beats.
- Locks override only specified fields.
- Probability is deterministic.
- Pitch behavior affects outgoing MIDI only through supported MIDI mechanisms.
- Scale quantization is predictable.

## Regression Risks

- Event sorting at identical beat positions.
- Floating point beat comparisons.
- Clip rotation with locked steps.
- Codable compatibility after data model changes.
- AUv3 host sync drift once adapter work begins.

## Manual QA Checklist

- Run the debug app and confirm play/stop behavior.
- Confirm MIDI notes reach a simple AU instrument or hardware destination.
- Confirm AUv3 host transport starts and stops output.
- Confirm locked CC values are emitted before note-on events.
