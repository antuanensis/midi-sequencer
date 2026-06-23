import XCTest
import LockEngine
import MidiCore
import SequencerCore
import TheoryEngine
import TransformEngine

final class SequencerEngineTests: XCTestCase {
    func testRendersNoteOnAndOffForSixteenStepClip() {
        let clip = MIDIClip(steps: Array(repeating: ClipStep(note: 60, gateLengthBeats: 0.10), count: 16))

        let events = SequencerEngine().render(clip: clip)

        XCTAssertEqual(events.count, 32)
        XCTAssertEqual(events.first, ScheduledMIDIEvent(beat: 0, event: .noteOn(note: 60, velocity: 100, channel: MIDIChannel(1))))
        XCTAssertEqual(events[1], ScheduledMIDIEvent(beat: 0.10, event: .noteOff(note: 60, velocity: 0, channel: MIDIChannel(1))))
        XCTAssertEqual(events.last, ScheduledMIDIEvent(beat: 3.85, event: .noteOff(note: 60, velocity: 0, channel: MIDIChannel(1))))
    }

    func testStepLocksOverrideSparseValuesAndEmitCCs() {
        var clip = MIDIClip(steps: Array(repeating: ClipStep(note: 60, velocity: 90), count: 16))
        clip.stepLocks[0] = StepLock(note: 64, velocity: 70, gateLengthBeats: 0.5, ccValues: [74: 20])

        let events = SequencerEngine().render(clip: clip)

        XCTAssertEqual(events[0], ScheduledMIDIEvent(beat: 0, event: .controlChange(controller: 74, value: 20, channel: MIDIChannel(1))))
        XCTAssertEqual(events[1], ScheduledMIDIEvent(beat: 0, event: .noteOn(note: 64, velocity: 70, channel: MIDIChannel(1))))
        XCTAssertTrue(events.contains(ScheduledMIDIEvent(beat: 0.5, event: .noteOff(note: 64, velocity: 0, channel: MIDIChannel(1)))))
    }

    func testProbabilityZeroSuppressesStepDeterministically() {
        var clip = MIDIClip(steps: Array(repeating: ClipStep(note: 60), count: 16))
        clip.stepLocks[0] = StepLock(probability: 0)

        let events = SequencerEngine().render(clip: clip, seed: 42)

        XCTAssertEqual(events.count, 30)
        XCTAssertFalse(events.contains(ScheduledMIDIEvent(beat: 0, event: .noteOn(note: 60, velocity: 100, channel: MIDIChannel(1)))))
    }

    func testPitchBehaviorCanSendCCRouteChannelTransposeProbabilityAndHarmony() {
        var clip = MIDIClip(steps: Array(repeating: ClipStep(note: 60), count: 16))
        clip.pitchBehaviorMap = PitchBehaviorMap([
            .pitchClass(0): PitchBehavior(ccValues: [74: 20]),
            .pitch(60): PitchBehavior(outputChannel: MIDIChannel(2), transposeOctaves: 1, probabilityMultiplier: 1, harmonyOffsets: [7])
        ])

        let events = SequencerEngine().render(clip: clip)

        XCTAssertTrue(events.contains(ScheduledMIDIEvent(beat: 0, event: .controlChange(controller: 74, value: 20, channel: MIDIChannel(2)))))
        XCTAssertTrue(events.contains(ScheduledMIDIEvent(beat: 0, event: .noteOn(note: 72, velocity: 100, channel: MIDIChannel(2)))))
        XCTAssertTrue(events.contains(ScheduledMIDIEvent(beat: 0, event: .noteOn(note: 79, velocity: 100, channel: MIDIChannel(2)))))
    }

    func testTransposeOctaveShiftRotateReverseAndQuantize() {
        let clip = MIDIClip(steps: [
            ClipStep(note: 60),
            ClipStep(note: 61),
            ClipStep(note: 62),
            ClipStep(note: 63)
        ])

        XCTAssertEqual(ClipTransforms.transpose(clip, semitones: 2).steps.map(\.note), [62, 63, 64, 65])
        XCTAssertEqual(ClipTransforms.octaveShift(clip, octaves: 1).steps.map(\.note), [72, 73, 74, 75])
        XCTAssertEqual(ClipTransforms.rotate(clip, steps: 1).steps.map(\.note), [63, 60, 61, 62])
        XCTAssertEqual(ClipTransforms.reverse(clip).steps.map(\.note), [63, 62, 61, 60])

        let cMajor = Scale(rootPitchClass: 0, mode: .major)
        XCTAssertEqual(ClipTransforms.quantize(clip, to: cMajor).steps.map(\.note), [60, 62, 62, 64])
    }
}
