import XCTest
import MidiCore
import SequencerCore

final class ExampleProjectsTests: XCTestCase {
    func testClipLabDemoRoundTripsThroughJSON() throws {
        let project = ExampleProjects.clipLabDemo()

        let data = try JSONEncoder().encode(project)
        let decoded = try JSONDecoder().decode(SequencerProject.self, from: data)

        XCTAssertEqual(decoded, project)
    }

    func testClipLabDemoRendersWindowedMIDIEvents() throws {
        let project = ExampleProjects.clipLabDemo()
        let clipID = try XCTUnwrap(project.tracks.first?.activeClipID)
        let clip = try XCTUnwrap(project.clip(id: clipID))

        let events = SequencerEngine().render(clip: clip, startBeat: 0, endBeat: 1, seed: 11, channel: MIDIChannel(1))

        XCTAssertFalse(events.isEmpty)
        XCTAssertTrue(events.contains { event in
            guard case .controlChange(controller: 74, _, _) = event.event else { return false }
            return true
        })
        XCTAssertTrue(events.contains { event in
            guard case .noteOn = event.event else { return false }
            return true
        })
    }
}
