# AGENTS.md

# MidiSequencer — Agent Instructions

## Project Identity

MidiSequencer is an iPad-first AUv3 MIDI processor and standalone debug app for fast clip sequencing, Elektron-style step locks, clip transforms, and per-note MIDI behavior rules.

## Current Phase

Phase 0: build and test the pure Swift sequencing engine before connecting AUv3 host sync, MIDI output, or complex UI.

## Core Principles

- Keep the sequencing engine independent from AUv3, SwiftUI, and host lifecycle concerns.
- Prefer small, complete, reviewable changes.
- Store locks as sparse overrides, not duplicated step data.
- Keep timing deterministic and testable.
- Treat model output and external MIDI/AUv3 inputs as untrusted until validated.
- Build a practical MIDI clip laboratory, not a decorative or generative composition system.

## Tech Stack

- Swift and Swift Package Manager for pure engine modules.
- XCTest for deterministic non-AUv3 tests.
- SwiftUI for the standalone/debug editor.
- Audio Unit v3 for the iPadOS MIDI processor plugin.
- Core MIDI / AU MIDI event handling at the adapter boundary only.

## Repository Structure

- `Sources/MidiCore`: MIDI note, channel, CC, event, and timing types.
- `Sources/SequencerCore`: clips, steps, tracks, playback state, deterministic rendering.
- `Sources/LockEngine`: sparse step locks and pitch behavior maps.
- `Sources/TransformEngine`: clip transforms such as transpose, octave shift, rotate, reverse, and quantize.
- `Sources/TheoryEngine`: roots, scales, modes, and scale quantization.
- `Tests`: unit tests for pure Swift logic.
- `specs/clip-midi-sequencer`: product and MVP specs.
- `docs`: durable project memory, architecture notes, ADRs, task tracking, devlog, and testing strategy.

## Development Workflow

1. Read this file.
2. Read `docs/tasks/active.md`.
3. Read relevant specs under `specs/clip-midi-sequencer`.
4. Inspect current code before changing it.
5. Make the smallest coherent change.
6. Add or update tests for changed behavior.
7. Run the most relevant checks.
8. Update docs and devlog when behavior, architecture, commands, or status changes.

## Testing Requirements

- Unit-test all non-AUv3 sequencing, lock, transform, probability, and quantization behavior.
- Do not require an AUv3 host to validate core sequencing logic.
- Use deterministic seeds for probability tests.
- Report skipped validation honestly.

## Documentation Requirements

- Meaningful features need a spec update.
- Meaningful architecture choices need an ADR.
- Meaningful implementation sessions need a devlog entry.
- Task files must reflect active work and next safe steps.

## Coding Standards

- Use explicit names and small pure modules.
- Keep domain logic separate from IO, UI, persistence, and AUv3 integration.
- Prefer Codable value types for project data.
- Avoid hidden global state and nondeterministic timing in core logic.
- Do not bury AUv3 or Core MIDI calls inside reusable sequencing code.

## Dependency Policy

- Do not add dependencies casually.
- Prefer Swift standard library, Apple frameworks, and existing project modules.
- Document significant dependency choices in an ADR.

## Security and Secrets

- Never commit API keys, tokens, credentials, certificates, personal data dumps, or local secrets.
- Use examples rather than real user data in fixtures.

## What Agents Must Not Do

- Do not build AI composition, clip genetics, audio DSP, complex MPE, advanced voice leading, or a phrase compiler during MVP.
- Do not start UI, AUv3, persistence, and engine rewrites in parallel.
- Do not claim arbitrary synth parameter support unless exposed through MIDI CC, MPE, channel routing, or AU parameters.
- Do not rewrite history, force-push, or run destructive git operations unless explicitly instructed.

## How To Handle Uncertainty

If a choice is small and reversible, choose the simplest option and document the assumption. If it affects architecture, persistence, security, AUv3 integration, or long-term compatibility, ask or create an ADR.

## Definition of Done

- Requested behavior exists.
- Code follows the documented architecture.
- Relevant tests were added or updated.
- Relevant checks were run where possible.
- Docs, task files, and devlog were updated when appropriate.
- No unrelated large refactors were introduced.
- Remaining risks and next steps are recorded.
