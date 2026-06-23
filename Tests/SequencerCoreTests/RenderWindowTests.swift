import XCTest
import MidiCore
import SequencerCore

final class RenderWindowTests: XCTestCase {
    func testRenderWindowMatchesFullRenderFilteredToBeatRange() {
        let clip = MIDIClip(
            steps: [
                ClipStep(note: 60, gateLengthBeats: 0.5),
                ClipStep(note: 62, gateLengthBeats: 0.25),
                ClipStep(note: 64, gateLengthBeats: 0.25),
                ClipStep(note: 65, gateLengthBeats: 0.25)
            ],
            lfos: [
                ClipLFO(id: "cc-lfo", destination: .cc(controller: 74), shape: .sine, rateCyclesPerBeat: 1, amplitude: 10, offset: 64)
            ]
        )
        let engine = SequencerEngine()
        let startBeat = 0.25
        let endBeat = 0.75

        let full = engine.render(clip: clip, loops: 1, seed: 7)
            .filter { $0.beat >= startBeat && $0.beat < endBeat }
        let window = engine.render(clip: clip, startBeat: startBeat, endBeat: endBeat, seed: 7)

        XCTAssertEqual(window, full)
        XCTAssertTrue(window.contains(ScheduledMIDIEvent(beat: 0.5, event: .noteOff(note: 60, velocity: 0, channel: MIDIChannel(1)))))
    }

    func testRenderWindowConsumesProbabilityDeterministicallyFromBeatZero() {
        let clip = MIDIClip(
            steps: [
                ClipStep(note: 60, probability: 0.25),
                ClipStep(note: 62, probability: 0.25),
                ClipStep(note: 64, probability: 0.25),
                ClipStep(note: 65, probability: 0.25)
            ]
        )
        let engine = SequencerEngine()
        let startBeat = 0.5
        let endBeat = 1.0

        let full = engine.render(clip: clip, loops: 1, seed: 99)
            .filter { $0.beat >= startBeat && $0.beat < endBeat }
        let window = engine.render(clip: clip, startBeat: startBeat, endBeat: endBeat, seed: 99)

        XCTAssertEqual(window, full)
    }

    func testInvalidRenderWindowReturnsNoEvents() {
        let engine = SequencerEngine()

        XCTAssertEqual(engine.render(clip: MIDIClip(), startBeat: 1, endBeat: 1), [])
        XCTAssertEqual(engine.render(clip: MIDIClip(), startBeat: 2, endBeat: 1), [])
    }
}
