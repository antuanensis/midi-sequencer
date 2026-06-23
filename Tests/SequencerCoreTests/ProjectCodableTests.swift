import XCTest
import LockEngine
import MidiCore
import SequencerCore
import TheoryEngine

final class ProjectCodableTests: XCTestCase {
    func testProjectRoundTripsThroughJSON() throws {
        var clip = MIDIClip(
            id: "clip-main",
            name: "Main",
            steps: Array(repeating: ClipStep(note: 60, velocity: 96, ccValues: [10: 64]), count: 16),
            stepLocks: [
                3: StepLock(note: 67, velocity: 81, gateLengthBeats: 0.5, probability: 0.75, octave: 1, ccValues: [74: 20])
            ],
            pitchBehaviorMap: PitchBehaviorMap([
                .pitchClass(0): PitchBehavior(ccValues: [74: 20]),
                .pitch(62): PitchBehavior(outputChannel: MIDIChannel(2), transposeOctaves: 1, probabilityMultiplier: 0.5, harmonyOffsets: [7])
            ]),
            lfos: [
                ClipLFO(id: "cc-lfo", destination: .cc(controller: 74), shape: .triangle, rateCyclesPerBeat: 1, amplitude: 10, offset: 64)
            ]
        )
        clip.beatsPerStep = 0.25

        let project = SequencerProject(
            id: "project-main",
            name: "Round Trip",
            tracks: [
                SequencerTrack(
                    id: "track-main",
                    name: "Lead",
                    midiChannel: MIDIChannel(3),
                    clipIDs: [clip.id],
                    activeClipID: clip.id
                )
            ],
            clips: [clip],
            defaultScale: Scale(rootPitchClass: 2, mode: .dorian),
            transformHistory: [
                .transpose(clipID: clip.id, semitones: 2),
                .quantize(clipID: clip.id, scale: Scale(rootPitchClass: 2, mode: .dorian))
            ]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(project)
        let decoded = try JSONDecoder().decode(SequencerProject.self, from: data)

        XCTAssertEqual(decoded, project)
        XCTAssertEqual(decoded.clip(id: clip.id), clip)
    }

    func testDefaultProjectIsOneTrackOneClip() {
        let project = SequencerProject()

        XCTAssertEqual(project.schemaVersion, .current)
        XCTAssertEqual(project.tracks.count, 1)
        XCTAssertEqual(project.clips.count, 1)
        XCTAssertEqual(project.tracks.first?.activeClipID, project.clips.first?.id)
    }

    func testPitchBehaviorMapEncodesAsStableEntryList() throws {
        let map = PitchBehaviorMap([
            .pitch(60): PitchBehavior(outputChannel: MIDIChannel(2)),
            .pitchClass(0): PitchBehavior(ccValues: [74: 20])
        ])

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let json = String(decoding: try encoder.encode(map), as: UTF8.self)

        XCTAssertTrue(json.contains("\"behaviors\""))
        XCTAssertTrue(json.contains("\"pitch\""))
        XCTAssertTrue(json.contains("\"pitchClass\""))
    }
}
