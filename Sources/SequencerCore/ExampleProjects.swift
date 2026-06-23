import LockEngine
import MidiCore
import TheoryEngine

public enum ExampleProjects {
    public static func clipLabDemo() -> SequencerProject {
        let clip = MIDIClip(
            id: "clip-lab-demo",
            name: "Clip Lab Demo",
            steps: [
                ClipStep(note: 60, velocity: 100, gateLengthBeats: 0.20, ccValues: [10: 48]),
                ClipStep(note: 62, velocity: 92, gateLengthBeats: 0.20),
                ClipStep(note: 64, velocity: 96, gateLengthBeats: 0.25),
                ClipStep(note: 67, velocity: 108, gateLengthBeats: 0.35),
                ClipStep(note: 72, velocity: 88, gateLengthBeats: 0.15),
                ClipStep(note: 67, velocity: 100, gateLengthBeats: 0.20),
                ClipStep(note: 64, velocity: 92, gateLengthBeats: 0.20),
                ClipStep(note: 62, velocity: 84, gateLengthBeats: 0.30),
                ClipStep(note: 60, velocity: 110, gateLengthBeats: 0.20),
                ClipStep(note: 62, velocity: 86, gateLengthBeats: 0.20),
                ClipStep(note: 64, velocity: 94, gateLengthBeats: 0.25),
                ClipStep(note: 67, velocity: 102, gateLengthBeats: 0.35),
                ClipStep(note: 72, velocity: 90, gateLengthBeats: 0.15),
                ClipStep(note: 67, velocity: 98, gateLengthBeats: 0.20),
                ClipStep(note: 64, velocity: 90, gateLengthBeats: 0.20),
                ClipStep(note: 55, velocity: 112, gateLengthBeats: 0.40)
            ],
            stepLocks: [
                3: StepLock(velocity: 120, gateLengthBeats: 0.50, ccValues: [74: 24]),
                7: StepLock(probability: 0.50),
                12: StepLock(octave: 1, ccValues: [71: 96])
            ],
            pitchBehaviorMap: PitchBehaviorMap([
                .pitchClass(0): PitchBehavior(ccValues: [74: 20]),
                .pitchClass(2): PitchBehavior(outputChannel: MIDIChannel(2)),
                .pitchClass(4): PitchBehavior(transposeOctaves: 1),
                .pitchClass(7): PitchBehavior(probabilityMultiplier: 0.75),
                .pitchClass(11): PitchBehavior(harmonyOffsets: [7])
            ]),
            lfos: [
                ClipLFO(id: "filter-motion", destination: .cc(controller: 74), shape: .sine, rateCyclesPerBeat: 0.25, amplitude: 24, offset: 64),
                ClipLFO(id: "probability-pulse", destination: .probability, shape: .triangle, rateCyclesPerBeat: 0.5, amplitude: 0.15, offset: 0)
            ]
        )

        return SequencerProject(
            id: "project-clip-lab-demo",
            name: "Clip Lab Demo",
            tracks: [
                SequencerTrack(
                    id: "track-main",
                    name: "Main",
                    midiChannel: MIDIChannel(1),
                    clipIDs: [clip.id],
                    activeClipID: clip.id
                )
            ],
            clips: [clip],
            defaultScale: Scale(rootPitchClass: 0, mode: .major),
            transformHistory: [
                .transpose(clipID: clip.id, semitones: 0),
                .quantize(clipID: clip.id, scale: Scale(rootPitchClass: 0, mode: .major))
            ]
        )
    }
}
