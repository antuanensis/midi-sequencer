import XCTest
import MidiCore
import SequencerCore

final class LFOTests: XCTestCase {
    func testLFOShapesAreDeterministicAtBeatPhases() {
        XCTAssertEqual(LFOShape.sine.value(phase: 0), 0, accuracy: 0.0001)
        XCTAssertEqual(LFOShape.sine.value(phase: 0.25), 1, accuracy: 0.0001)
        XCTAssertEqual(LFOShape.triangle.value(phase: 0.25), 1, accuracy: 0.0001)
        XCTAssertEqual(LFOShape.square.value(phase: 0.25), 1, accuracy: 0.0001)
        XCTAssertEqual(LFOShape.square.value(phase: 0.75), -1, accuracy: 0.0001)
    }

    func testCCLFOEmitsBeatClockedControllerValues() {
        let clip = MIDIClip(
            steps: [
                ClipStep(note: 60),
                ClipStep(note: 62)
            ],
            lfos: [
                ClipLFO(id: "cc-lfo", destination: .cc(controller: 74), shape: .sine, rateCyclesPerBeat: 1, amplitude: 10, offset: 64)
            ]
        )

        let events = SequencerEngine().render(clip: clip)

        XCTAssertTrue(events.contains(ScheduledMIDIEvent(beat: 0, event: .controlChange(controller: 74, value: 64, channel: MIDIChannel(1)))))
        XCTAssertTrue(events.contains(ScheduledMIDIEvent(beat: 0.25, event: .controlChange(controller: 74, value: 74, channel: MIDIChannel(1)))))
    }

    func testProbabilityLFOCanModulateStepPlaybackDeterministically() {
        let clip = MIDIClip(
            steps: [
                ClipStep(note: 60, probability: 0),
                ClipStep(note: 62, probability: 0)
            ],
            lfos: [
                ClipLFO(id: "probability-lfo", destination: .probability, shape: .square, rateCyclesPerBeat: 1, amplitude: 1, offset: 0)
            ]
        )

        let events = SequencerEngine().render(clip: clip, seed: 1)

        XCTAssertTrue(events.contains(ScheduledMIDIEvent(beat: 0, event: .noteOn(note: 60, velocity: 100, channel: MIDIChannel(1)))))
        XCTAssertTrue(events.contains(ScheduledMIDIEvent(beat: 0.25, event: .noteOn(note: 62, velocity: 100, channel: MIDIChannel(1)))))
    }
}
