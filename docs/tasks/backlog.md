# Backlog

## Stream 1: Finish The Pure Engine

- [x] Add project-level Codable models.
  - Description: Create Codable `Project`, `Track`, clip collection, global theory settings, and schema version types.
  - Why: The product vision includes save/load project data and a one-track, one-clip MVP. This converts the current clip-only engine into the smallest real project model.
  - Implement after: current engine skeleton.
  - Implement before: persistence, fixtures, SwiftUI editor, AUv3 state.

- [x] Add explicit transform command metadata.
  - Description: Model operations such as duplicate, delete, transpose, octave shift, rotate, reverse, and quantize as serializable commands or history entries.
  - Why: The original idea says clip transformations should be explicit and serializable. This lets the app explain and persist what happened instead of only baking anonymous note changes.
  - Implement after: project-level Codable models.
  - Implement before: UI transform controls and persistence migration decisions.

- [x] Define delete clip semantics for the one-clip MVP.
  - Description: Decide whether deleting the only clip creates an empty default clip, leaves an empty track, or blocks deletion.
  - Why: Delete is part of the MVP clip operations, but a one-track/one-clip app needs predictable behavior before UI controls expose it.
  - Implement after: project and track models.
  - Implement before: SwiftUI clip operations.

- [x] Add project-state transform application API.
  - Description: Apply `ClipTransformCommand` values to `SequencerProject`, update affected clips/tracks, and append successful commands to transform history.
  - Why: The app needs one canonical path for UI, fixtures, persistence, and future AUv3 state changes to mutate clips. Otherwise transforms risk becoming duplicated in UI actions and tests.
  - Implement after: delete clip semantics.
  - Implement before: fixture projects and SwiftUI transform controls.

- [x] Add deterministic LFO model and tests.
  - Description: Add beat-clocked LFO definitions with phase, shape, rate, depth, and MIDI-safe destinations such as CC value modulation or probability modulation.
  - Why: LFO capability is in the original MVP, but it must support the project vision without becoming overcomplicated modulation. Keeping it deterministic makes it testable and AUv3-safe.
  - Implement after: project model and transform metadata.
  - Implement before: UI modulation controls or AUv3 output.

- [x] Add render-window playback API.
  - Description: Render events for a beat range instead of only full loops.
  - Why: The current engine can prove deterministic clip output, but host sync and live playback need windowed rendering to avoid regenerating whole clips on every callback.
  - Implement after: project model and LFO basics.
  - Implement before: debug transport and AUv3 host sync.

- [x] Add fixture projects and demo clips.
  - Description: Create small Codable fixtures showing step locks, pitch behavior, transforms, quantization, and LFO behavior.
  - Why: Fixtures turn the product vision into concrete examples and give tests plus UI work realistic material.
  - Implement after: Codable project model and LFO model.
  - Implement before: standalone/debug app.

## Stream 2: Build The Standalone Debug App

- [ ] Create Xcode iPad app target using the SwiftPM engine.
  - Description: Add the smallest standalone/debug shell that can load project state and call the pure engine.
  - Why: The MVP says a user should be able to run the debug app, press play, and receive deterministic MIDI output. This is the first user-visible layer.
  - Implement after: engine fixtures.
  - Implement before: SwiftUI editor surfaces.

- [ ] Build SwiftUI 16-step clip grid.
  - Description: Show one clip as 16 stable step cells with note, lock, and playback state indicators.
  - Why: The app should feel like a fast tactile clip lab, and the grid is the primary editing surface for Ableton-style clip usefulness and Elektron-style locks.
  - Implement after: app target.
  - Implement before: detailed lock editor.

- [ ] Build step and lock editor.
  - Description: Edit note, velocity, gate length, probability, octave, and CC locks for the selected step.
  - Why: Step locks are a central differentiator of the original idea, so the debug app must make them practical before broader polish.
  - Implement after: clip grid.
  - Implement before: performance controls or multi-track UI.

- [ ] Add basic clip operation controls.
  - Description: Expose duplicate, delete, transpose, octave shift, rotate, reverse, and quantize using tested transform commands.
  - Why: Clip manipulation is the core product promise. These controls make the engine usable as a laboratory rather than a static sequencer.
  - Implement after: transform metadata and step editor.
  - Implement before: AUv3 integration.

- [ ] Connect debug transport to render-window API.
  - Description: Add play/stop state and beat-clocked playback using the engine's windowed rendering.
  - Why: The MVP requires pressing play and receiving deterministic MIDI output. The standalone transport is the simplest way to test that without host variability.
  - Implement after: render-window API and app shell.
  - Implement before: debug MIDI destination output.

- [ ] Add debug MIDI destination output.
  - Description: Send rendered MIDI events to a selected local/Core MIDI destination for manual testing.
  - Why: Users need to hear or inspect the engine output before AUv3 host work begins.
  - Implement after: debug transport.
  - Implement before: AUv3 output bridge.

## Stream 3: Add Persistence

- [ ] Implement persistence module.
  - Description: Save and load project files through Codable types with a stable schema version.
  - Why: Project files are required by the original idea, and persistence should be built around canonical state rather than UI or AUv3 runtime objects.
  - Implement after: project-level models and fixtures.
  - Implement before: project browser or long-term user workflows.

- [ ] Add Codable migration strategy.
  - Description: Define how schema changes are handled as clips, transforms, pitch behavior, and LFOs evolve.
  - Why: This keeps early project files from becoming disposable once the engine grows.
  - Implement after: first persistence module.
  - Implement before: public beta or shared fixtures.

- [ ] Add persistent project browser.
  - Description: Let the debug app list, open, duplicate, and delete saved projects.
  - Why: Useful for real work, but not needed before a single deterministic debug project can play.
  - Implement after: persistence module and debug app basics.
  - Implement before: broader workflow polish.

## Stream 4: Connect AUv3 After The Engine Works

- [ ] Create minimal AUv3 MIDI processor target.
  - Description: Add the app extension shell and required target wiring while keeping sequencing logic in SwiftPM modules.
  - Why: AUv3 is essential to the product, but the architecture rule says it should be an adapter over the tested engine.
  - Implement after: debug playback and MIDI output prove engine behavior.
  - Implement before: host sync validation.

- [ ] Add host tempo and transport adapter tests.
  - Description: Test translation from host tempo, beat position, and transport state into engine render windows.
  - Why: Host sync is part of the MVP, and adapter tests catch drift without requiring every check to launch an AUv3 host.
  - Implement after: render-window API and AUv3 shell.
  - Implement before: manual host validation.

- [ ] Bridge scheduled events to AU MIDI output.
  - Description: Convert engine `ScheduledMIDIEvent` values to AUv3 MIDI output at the correct sample/beat timing.
  - Why: This is the point where the sequencer becomes a real AUv3 MIDI processor rather than only a debug app.
  - Implement after: host adapter tests.
  - Implement before: host QA.

- [ ] Validate in at least two iPad AUv3 hosts.
  - Description: Manually test transport sync, note output, CC locks, probability, and state restore in real hosts.
  - Why: AUv3 behavior varies by host. The product cannot claim useful host integration until it survives real host timing.
  - Implement after: AU MIDI output bridge.
  - Implement before: TestFlight or wider release.

## Stream 5: Later Product Growth

- [ ] Add multi-track sequencing.
  - Description: Expand from one track to multiple tracks with independent MIDI channels and clips.
  - Why: Valuable for a mature clip laboratory, but not necessary for the first usable one-track MVP.
  - Implement after: one-track AUv3 MVP.

- [ ] Add performance macros for common clip operations.
  - Description: Group transform actions into performable controls.
  - Why: This supports the tactile performance direction, but should wait until core operations and UI are stable.
  - Implement after: clip operations are proven in the debug app.

- [ ] Add more scales and modes.
  - Description: Expand theory support beyond the initial modes.
  - Why: Useful for musical breadth, but the initial quantization behavior matters more than scale catalog size.
  - Implement after: project persistence and basic scale UI.

- [ ] Evaluate optional MPE lane.
  - Description: Research whether limited MPE behavior should be added without breaking the clean MIDI-first architecture.
  - Why: The original MVP explicitly avoids complex MPE. Any MPE work should be small, optional, and justified by real use cases.
  - Implement after: stable AUv3 MVP.

- [ ] Add macOS support.
  - Description: Adapt app/plugin targets for macOS if the iPad-first architecture transfers cleanly.
  - Why: macOS is later, not required for MVP.
  - Implement after: iPadOS MVP is usable.

## Explicit Non-Goals For Now

- [ ] AI composition.
  - Why not now: The product direction is practical clip manipulation, not generated musical authorship.

- [ ] Clip genetics.
  - Why not now: It would distract from deterministic transforms and clear user intent.

- [ ] Audio DSP.
  - Why not now: The app is a MIDI processor, not an audio instrument or effect.

- [ ] Advanced voice leading.
  - Why not now: Harmony notes are allowed as MIDI behavior, but advanced arranging logic is beyond the MVP.

- [ ] Decorative UI.
  - Why not now: The UX should be utilitarian, dense, and tactile for repeated editing.

- [ ] Generative phrase compiler.
  - Why not now: The first product promise is editable clips with deterministic behavior.
