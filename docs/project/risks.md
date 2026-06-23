# Project Risks

- AUv3 host timing behavior can vary by host.
- MIDI processor app extension setup requires Xcode entitlements and host testing that SwiftPM alone cannot cover.
- UI work can outrun the engine if not kept behind tested sequencing behavior.
- Codable persistence must stay compatible as the model evolves.
- Probability and LFO behavior can become nondeterministic unless seeded and clocked carefully.
