import Foundation
import LockEngine
import MidiCore
import SequencerCore
import TheoryEngine

@MainActor
public final class ClipLabDebugViewModel: ObservableObject {
    @Published public private(set) var project: SequencerProject
    @Published public var selectedClipID: String
    @Published public var selectedStepIndex: Int
    @Published public var isPlaying: Bool

    private let engine: SequencerEngine
    private let renderSeed: UInt64

    public init(
        project: SequencerProject = ExampleProjects.clipLabDemo(),
        engine: SequencerEngine = SequencerEngine(),
        renderSeed: UInt64 = 1
    ) {
        self.project = project
        self.engine = engine
        self.renderSeed = renderSeed
        self.selectedClipID = project.tracks.first?.activeClipID ?? project.clips.first?.id ?? ""
        self.selectedStepIndex = 0
        self.isPlaying = false
    }

    public var activeTrack: SequencerTrack? {
        project.tracks.first { $0.activeClipID == selectedClipID } ?? project.tracks.first
    }

    public var activeClip: MIDIClip? {
        project.clip(id: selectedClipID) ?? project.clips.first
    }

    public var clipSummaries: [ClipSummary] {
        project.clips.map { clip in
            ClipSummary(
                id: clip.id,
                name: clip.name,
                stepCount: clip.steps.count,
                lockCount: clip.stepLocks.count,
                pitchBehaviorCount: clip.pitchBehaviorMap.behaviors.count,
                lfoCount: clip.lfos.count,
                isSelected: clip.id == selectedClipID
            )
        }
    }

    public var stepSummaries: [ClipStepSummary] {
        guard let clip = activeClip else { return [] }

        return clip.steps.indices.map { index in
            let base = clip.steps[index]
            let lock = clip.stepLocks[index]
            let resolved = base.applying(lock: lock)

            return ClipStepSummary(
                index: index,
                baseNoteName: Self.noteName(for: base.note),
                resolvedNoteName: Self.noteName(for: resolved.note + resolved.octave * 12),
                velocity: resolved.velocity,
                gateLengthBeats: resolved.gateLengthBeats,
                probability: resolved.probability,
                octave: resolved.octave,
                ccCount: resolved.ccValues.count,
                lockedFieldLabels: Self.lockedFieldLabels(for: lock),
                isSelected: index == selectedStepIndex
            )
        }
    }

    public var selectedStepSummary: ClipStepSummary? {
        stepSummaries.first { $0.index == selectedStepIndex }
    }

    public var renderedEventRows: [RenderedEventRow] {
        guard let clip = activeClip else { return [] }
        let channel = activeTrack?.midiChannel ?? MIDIChannel(1)

        return engine.render(
            clip: clip,
            startBeat: 0,
            endBeat: clip.lengthBeats,
            seed: renderSeed,
            channel: channel
        )
        .enumerated()
        .map { index, event in
            RenderedEventRow(index: index, scheduledEvent: event)
        }
    }

    public var pitchBehaviorSummaries: [String] {
        guard let clip = activeClip else { return [] }

        return clip.pitchBehaviorMap.behaviors
            .map { target, behavior in
                let targetLabel: String
                switch target {
                case .pitch(let note):
                    targetLabel = "Note \(Self.noteName(for: note))"
                case .pitchClass(let pitchClass):
                    targetLabel = "Class \(Self.noteName(for: pitchClass))"
                }

                var behaviors: [String] = []
                if !behavior.ccValues.isEmpty {
                    behaviors.append("CC")
                }
                if let outputChannel = behavior.outputChannel {
                    behaviors.append("Ch \(outputChannel.value)")
                }
                if behavior.transposeOctaves != 0 {
                    behaviors.append("Oct \(behavior.transposeOctaves)")
                }
                if behavior.probabilityMultiplier != 1 {
                    behaviors.append("Prob \(Self.percentString(behavior.probabilityMultiplier))")
                }
                if !behavior.harmonyOffsets.isEmpty {
                    behaviors.append("Harmony")
                }

                return "\(targetLabel): \(behaviors.joined(separator: ", "))"
            }
            .sorted()
    }

    public var lfoSummaries: [String] {
        guard let clip = activeClip else { return [] }

        return clip.lfos.map { lfo in
            "\(lfo.id): \(lfo.shape.rawValue) -> \(Self.lfoDestinationLabel(lfo.destination))"
        }
    }

    public var scaleSummary: String {
        "\(Self.noteName(for: project.defaultScale.rootPitchClass)) \(project.defaultScale.mode.rawValue)"
    }

    public func selectClip(id: String) {
        guard project.clip(id: id) != nil else { return }
        selectedClipID = id
        selectedStepIndex = 0
    }

    public func selectStep(index: Int) {
        guard let clip = activeClip else { return }
        selectedStepIndex = min(max(index, 0), clip.steps.count - 1)
    }

    public func togglePlayback() {
        isPlaying.toggle()
    }

    public nonisolated static func noteName(for midiNote: Int) -> String {
        let names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let pitchClass = ((midiNote % 12) + 12) % 12
        let octave = (midiNote / 12) - 1
        return "\(names[pitchClass])\(octave)"
    }

    public nonisolated static func percentString(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private nonisolated static func lockedFieldLabels(for lock: StepLock?) -> [String] {
        guard let lock else { return [] }

        var labels: [String] = []
        if lock.note != nil { labels.append("Note") }
        if lock.velocity != nil { labels.append("Vel") }
        if lock.gateLengthBeats != nil { labels.append("Gate") }
        if lock.probability != nil { labels.append("Prob") }
        if lock.octave != nil { labels.append("Oct") }
        labels.append(contentsOf: lock.ccValues.keys.sorted().map { "CC\($0)" })
        return labels
    }

    private nonisolated static func lfoDestinationLabel(_ destination: LFODestination) -> String {
        switch destination {
        case .cc(let controller):
            return "CC\(controller)"
        case .probability:
            return "Probability"
        }
    }
}

public struct ClipSummary: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let stepCount: Int
    public let lockCount: Int
    public let pitchBehaviorCount: Int
    public let lfoCount: Int
    public let isSelected: Bool
}

public struct ClipStepSummary: Identifiable, Equatable, Sendable {
    public var id: Int { index }

    public let index: Int
    public let baseNoteName: String
    public let resolvedNoteName: String
    public let velocity: Int
    public let gateLengthBeats: Double
    public let probability: Double
    public let octave: Int
    public let ccCount: Int
    public let lockedFieldLabels: [String]
    public let isSelected: Bool

    public var hasLocks: Bool {
        !lockedFieldLabels.isEmpty
    }
}

public struct RenderedEventRow: Identifiable, Equatable, Sendable {
    public var id: Int { index }

    public let index: Int
    public let beat: Double
    public let kind: String
    public let detail: String
    public let channel: Int

    public init(index: Int, scheduledEvent: ScheduledMIDIEvent) {
        self.index = index
        self.beat = scheduledEvent.beat

        switch scheduledEvent.event {
        case .controlChange(let controller, let value, let channel):
            self.kind = "CC"
            self.detail = "CC\(controller) = \(value)"
            self.channel = channel.value
        case .noteOn(let note, let velocity, let channel):
            self.kind = "On"
            self.detail = "\(ClipLabDebugViewModel.noteName(for: note)) vel \(velocity)"
            self.channel = channel.value
        case .noteOff(let note, _, let channel):
            self.kind = "Off"
            self.detail = "\(ClipLabDebugViewModel.noteName(for: note))"
            self.channel = channel.value
        }
    }
}
