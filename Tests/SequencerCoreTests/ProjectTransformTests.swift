import XCTest
import MidiCore
import SequencerCore
import TheoryEngine
import TransformEngine

final class ProjectTransformTests: XCTestCase {
    func testDuplicateAddsClipToReferencingTrackAndMakesItActive() throws {
        let project = SequencerProject()

        let transformed = try project.applying(.duplicate(sourceClipID: "clip-1", newClipID: "clip-copy"))

        XCTAssertEqual(transformed.clips.map(\.id), ["clip-1", "clip-copy"])
        XCTAssertEqual(transformed.tracks.first?.clipIDs, ["clip-1", "clip-copy"])
        XCTAssertEqual(transformed.tracks.first?.activeClipID, "clip-copy")
        XCTAssertEqual(transformed.transformHistory, [.duplicate(sourceClipID: "clip-1", newClipID: "clip-copy")])
    }

    func testDeleteRemovesClipReferencesAndFallsBackToRemainingClip() throws {
        var project = SequencerProject()
        try project.apply(.duplicate(sourceClipID: "clip-1", newClipID: "clip-copy"))

        let transformed = try project.applying(.delete(clipID: "clip-copy"))

        XCTAssertEqual(transformed.clips.map(\.id), ["clip-1"])
        XCTAssertEqual(transformed.tracks.first?.clipIDs, ["clip-1"])
        XCTAssertEqual(transformed.tracks.first?.activeClipID, "clip-1")
        XCTAssertEqual(transformed.transformHistory.last, .delete(clipID: "clip-copy"))
    }

    func testDeleteLastClipLeavesEmptyTrackWithoutActiveClip() throws {
        let transformed = try SequencerProject().applying(.delete(clipID: "clip-1"))

        XCTAssertTrue(transformed.clips.isEmpty)
        XCTAssertEqual(transformed.tracks.first?.clipIDs, [])
        XCTAssertNil(transformed.tracks.first?.activeClipID)
        XCTAssertEqual(transformed.transformHistory, [.delete(clipID: "clip-1")])
    }

    func testTransformCommandsUpdateClipAndRecordHistory() throws {
        let project = SequencerProject()

        let transformed = try project
            .applying(.transpose(clipID: "clip-1", semitones: 2))
            .applying(.rotate(clipID: "clip-1", steps: 1))
            .applying(.quantize(clipID: "clip-1", scale: Scale(rootPitchClass: 0, mode: .major)))

        XCTAssertEqual(transformed.clips.first?.steps.first?.note, 62)
        XCTAssertEqual(transformed.transformHistory.count, 3)
    }

    func testMissingClipDoesNotRecordHistory() {
        var project = SequencerProject()

        XCTAssertThrowsError(try project.apply(.reverse(clipID: "missing"))) { error in
            XCTAssertEqual(error as? ProjectTransformError, .clipNotFound("missing"))
        }
        XCTAssertTrue(project.transformHistory.isEmpty)
    }

    func testDuplicateExistingClipIDDoesNotRecordHistory() {
        var project = SequencerProject()

        XCTAssertThrowsError(try project.apply(.duplicate(sourceClipID: "clip-1", newClipID: "clip-1"))) { error in
            XCTAssertEqual(error as? ProjectTransformError, .duplicateClipID("clip-1"))
        }
        XCTAssertTrue(project.transformHistory.isEmpty)
    }
}
