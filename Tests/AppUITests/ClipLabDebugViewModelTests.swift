import AppUI
import XCTest

@MainActor
final class ClipLabDebugViewModelTests: XCTestCase {
    func testLoadsDemoClipAsPrimaryObject() {
        let viewModel = ClipLabDebugViewModel()

        XCTAssertEqual(viewModel.clipSummaries.count, 1)
        XCTAssertEqual(viewModel.clipSummaries.first?.name, "Clip Lab Demo")
        XCTAssertEqual(viewModel.clipSummaries.first?.stepCount, 16)
        XCTAssertEqual(viewModel.clipSummaries.first?.lockCount, 3)
        XCTAssertEqual(viewModel.activeClip?.name, "Clip Lab Demo")
    }

    func testStepSummariesExposeSparseLocksWithoutHidingResolvedValues() {
        let viewModel = ClipLabDebugViewModel()

        XCTAssertEqual(viewModel.stepSummaries.count, 16)
        XCTAssertEqual(viewModel.stepSummaries[3].lockedFieldLabels, ["Vel", "Gate", "CC74"])
        XCTAssertEqual(viewModel.stepSummaries[7].lockedFieldLabels, ["Prob"])
        XCTAssertEqual(viewModel.stepSummaries[12].lockedFieldLabels, ["Oct", "CC71"])
        XCTAssertEqual(viewModel.stepSummaries[12].resolvedNoteName, "C6")
    }

    func testRenderedEventRowsComeFromActiveClip() {
        let viewModel = ClipLabDebugViewModel()

        XCTAssertFalse(viewModel.renderedEventRows.isEmpty)
        XCTAssertEqual(viewModel.renderedEventRows.first?.beat, 0)
        XCTAssertEqual(viewModel.renderedEventRows.first?.kind, "CC")
        XCTAssertEqual(viewModel.renderedEventRows.first?.channel, 1)
    }

    func testStepSelectionClampsToClipBounds() {
        let viewModel = ClipLabDebugViewModel()

        viewModel.selectStep(index: 99)
        XCTAssertEqual(viewModel.selectedStepIndex, 15)

        viewModel.selectStep(index: -4)
        XCTAssertEqual(viewModel.selectedStepIndex, 0)
    }
}
