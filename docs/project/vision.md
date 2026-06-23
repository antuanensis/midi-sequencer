# Project Vision

## One-Sentence Description

MidiSequencer is an iPad-first AUv3 MIDI processor for fast clip sequencing, sparse step locks, deterministic transforms, and per-note MIDI behavior rules.

## Problem / Opportunity

Many iPad MIDI sequencers are either linear, decorative, generative-first, or hard to test. This project focuses on practical manipulation of short clips: duplicate, transform, perform, and route MIDI with predictable timing.

## Intended Users

- iPad musicians sequencing external hardware or AU instruments.
- Producers who like Ableton-style clips and Elektron-style per-step locks.
- Users who want precise MIDI rules per step, pitch, pitch class, or channel.

## Core Use Cases

- Build a 16-step clip and hear deterministic MIDI output.
- Lock note, velocity, gate length, probability, octave, and CC values per step.
- Transform clips by transpose, octave shift, rotate, reverse, and scale quantize.
- Define pitch behavior such as CC output, channel routing, octave transposition, probability reduction, or harmony notes.

## Success Criteria

- Core sequencing logic is testable without AUv3 host launch.
- MVP can render a one-track, one-clip loop deterministically.
- AUv3 integration is a thin adapter over the pure engine.
- UI enables fast tactile editing without decorative complexity.

## Constraints

- iPadOS first.
- AUv3 MIDI processor plugin.
- Swift and SwiftUI.
- No audio DSP in MVP.
- Project files must be Codable.

## Current Assumptions

- Swift Package Manager is the right first container for pure engine modules and XCTest.
- Xcode project/app-extension scaffolding can be added after the engine stabilizes.
- Host sync can begin with a minimal adapter and deterministic timing tests around translated transport state.

## Non-Goals

- AI composition.
- Clip genetics.
- Complex MPE.
- Advanced voice leading.
- Audio DSP.
- Decorative UI.
- Generative phrase compiler.
