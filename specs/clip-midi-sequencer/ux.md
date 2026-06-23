# UX Spec

## Product Feel

The app should feel like a fast, tactile MIDI clip laboratory.

## Clip-Centric Model

The primary editable object is the MIDI clip. Notes are values inside clip steps, and locks, probability, transforms, scale quantization, pitch behavior, and LFO modulation are clip data or clip projections. UI copy and layout should avoid presenting the product as a generic note sequencer or piano-roll editor.

## MVP Views

- Clip grid with 16 steps.
- Step editor for note, velocity, gate, probability, octave, and CC locks.
- Clip operation controls for duplicate, delete, transpose, octave shift, rotate, reverse, and quantize.
- Basic scale selector for root and mode.
- Play/stop controls in the standalone/debug app.

## UI Principles

- Functional density over decorative layout.
- Clear touch targets for iPad.
- No marketing hero screens inside the working app.
- Show locked values distinctly without hiding base step values.
- Keep MIDI behavior legible: CC, channel, probability, and harmony changes should be inspectable.

## Deferred UX

- Multi-scene browser.
- Advanced modulation pages.
- Performance macros.
- Polished onboarding.
