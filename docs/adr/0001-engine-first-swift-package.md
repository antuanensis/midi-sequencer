# ADR 0001: Engine-First Swift Package

## Status

Accepted

## Date

2026-06-23

## Context

The project needs an AUv3 MIDI processor, standalone debug UI, deterministic tests, and Codable project data. AUv3 hosts are cumbersome for core logic testing, and UI work can easily outrun sequencing correctness.

## Decision

Start with Swift Package Manager pure Swift targets for MIDI, locks, theory, sequencing, and transforms. Add AUv3 and SwiftUI app targets after the engine can render deterministic MIDI events under test.

## Alternatives Considered

- Create the full Xcode iPad app and AUv3 extension first.
- Put all sequencing code directly in an AUv3 target.
- Use third-party sequencing or music theory libraries immediately.

## Consequences

Core sequencing can be tested quickly with `swift test`. AUv3 integration is delayed, but the adapter boundary should be cleaner. Some app-extension setup work remains for a later milestone.

## Follow-Up Tasks

- Expand engine coverage.
- Add Codable project-level models.
- Create the Xcode app and AUv3 extension after Milestone 1.
