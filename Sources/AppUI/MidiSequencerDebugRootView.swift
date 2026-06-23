import SwiftUI

@MainActor
public struct MidiSequencerDebugRootView: View {
    @StateObject private var viewModel: ClipLabDebugViewModel

    public init() {
        _viewModel = StateObject(wrappedValue: ClipLabDebugViewModel())
    }

    public init(viewModel: ClipLabDebugViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            TransportBar(viewModel: viewModel)
            Divider().overlay(AppColors.divider)

            HStack(alignment: .top, spacing: 14) {
                ClipSidebar(viewModel: viewModel)

                VStack(alignment: .leading, spacing: 14) {
                    ClipGrid(viewModel: viewModel)

                    HStack(alignment: .top, spacing: 14) {
                        RulePanel(title: "Pitch Rules", rows: viewModel.pitchBehaviorSummaries)
                        RulePanel(title: "Clip LFO", rows: viewModel.lfoSummaries)
                        TransformPlaceholder(scaleSummary: viewModel.scaleSummary)
                    }
                }

                StepInspector(viewModel: viewModel)
            }
            .padding(16)

            EventLog(rows: viewModel.renderedEventRows)
        }
        .frame(minWidth: 980, minHeight: 680)
        .background(AppColors.background)
        .foregroundStyle(AppColors.primaryText)
    }
}

private enum AppColors {
    static let background = Color(red: 0.07, green: 0.08, blue: 0.09)
    static let panel = Color(red: 0.11, green: 0.12, blue: 0.13)
    static let panelAlt = Color(red: 0.14, green: 0.15, blue: 0.16)
    static let divider = Color(red: 0.25, green: 0.27, blue: 0.29)
    static let primaryText = Color(red: 0.92, green: 0.93, blue: 0.92)
    static let secondaryText = Color(red: 0.62, green: 0.65, blue: 0.67)
    static let lockAccent = Color(red: 1.00, green: 0.68, blue: 0.28)
    static let playAccent = Color(red: 0.37, green: 0.84, blue: 0.65)
    static let pitchAccent = Color(red: 0.42, green: 0.70, blue: 1.00)
    static let danger = Color(red: 0.95, green: 0.32, blue: 0.35)
}

private struct TransportBar: View {
    @ObservedObject var viewModel: ClipLabDebugViewModel

    var body: some View {
        HStack(spacing: 14) {
            Text("MidiSequencer")
                .font(.headline.weight(.semibold))

            if let clip = viewModel.activeClip {
                Text(clip.name)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            StatusPill(label: "Clip", value: "\(viewModel.activeClip?.steps.count ?? 0) steps")
            StatusPill(label: "Scale", value: viewModel.scaleSummary)
            StatusPill(label: "Host", value: "Debug")
            StatusPill(label: "MIDI", value: "Ch \(viewModel.activeTrack?.midiChannel.value ?? 1)")

            Button(action: viewModel.togglePlayback) {
                Label(viewModel.isPlaying ? "Stop" : "Play", systemImage: viewModel.isPlaying ? "stop.fill" : "play.fill")
                    .labelStyle(.titleAndIcon)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(viewModel.isPlaying ? AppColors.danger : AppColors.playAccent)
                    .foregroundStyle(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.panel)
    }
}

private struct StatusPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppColors.secondaryText)
            Text(value)
                .font(.caption.weight(.medium))
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppColors.panelAlt)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ClipSidebar: View {
    @ObservedObject var viewModel: ClipLabDebugViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PanelHeader(title: "Clips", detail: "Primary object")

            ForEach(viewModel.clipSummaries) { clip in
                Button {
                    viewModel.selectClip(id: clip.id)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(clip.name)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(clip.stepCount)")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(AppColors.secondaryText)
                        }

                        HStack(spacing: 6) {
                            MiniBadge(text: "\(clip.lockCount) locks", color: AppColors.lockAccent)
                            MiniBadge(text: "\(clip.pitchBehaviorCount) rules", color: AppColors.pitchAccent)
                            MiniBadge(text: "\(clip.lfoCount) LFO", color: AppColors.playAccent)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(clip.isSelected ? AppColors.panelAlt : AppColors.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(clip.isSelected ? AppColors.pitchAccent : AppColors.divider, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 220, alignment: .topLeading)
        .padding(12)
        .background(AppColors.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ClipGrid: View {
    @ObservedObject var viewModel: ClipLabDebugViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PanelHeader(title: "Active Clip", detail: "16-step sparse lock grid")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.stepSummaries) { step in
                        StepCell(step: step) {
                            viewModel.selectStep(index: step.index)
                        }
                    }
                }
                .padding(.bottom, 2)
            }
        }
        .padding(12)
        .background(AppColors.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct StepCell: View {
    let step: ClipStepSummary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(step.index + 1)")
                        .font(.caption.monospacedDigit().weight(.semibold))
                    Spacer()
                    if step.hasLocks {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(AppColors.lockAccent)
                    }
                }

                Text(step.resolvedNoteName)
                    .font(.title3.monospacedDigit().weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                VStack(alignment: .leading, spacing: 3) {
                    Text("V \(step.velocity)")
                    Text("G \(formatBeat(step.gateLengthBeats))")
                    Text("P \(ClipLabDebugViewModel.percentString(step.probability))")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(AppColors.secondaryText)

                HStack(spacing: 3) {
                    ForEach(step.lockedFieldLabels.prefix(3), id: \.self) { label in
                        Text(label)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(AppColors.lockAccent.opacity(0.18))
                            .foregroundStyle(AppColors.lockAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .frame(height: 18, alignment: .leading)
            }
            .frame(width: 76, height: 136, alignment: .topLeading)
            .padding(8)
            .background(step.isSelected ? AppColors.panelAlt : AppColors.background)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(step.isSelected ? AppColors.playAccent : (step.hasLocks ? AppColors.lockAccent : AppColors.divider))
                    .frame(height: 3)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(step.isSelected ? AppColors.playAccent : AppColors.divider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

private struct StepInspector: View {
    @ObservedObject var viewModel: ClipLabDebugViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PanelHeader(title: "Clip Step Inspector", detail: "Overrides inside clip")

            if let step = viewModel.selectedStepSummary {
                InspectorRow(label: "Step", value: "\(step.index + 1)")
                InspectorRow(label: "Base note", value: step.baseNoteName)
                InspectorRow(label: "Resolved", value: step.resolvedNoteName)
                InspectorRow(label: "Velocity", value: "\(step.velocity)")
                InspectorRow(label: "Gate", value: formatBeat(step.gateLengthBeats))
                InspectorRow(label: "Probability", value: ClipLabDebugViewModel.percentString(step.probability))
                InspectorRow(label: "Octave", value: "\(step.octave)")
                InspectorRow(label: "CC values", value: "\(step.ccCount)")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Locks")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.secondaryText)

                    if step.lockedFieldLabels.isEmpty {
                        Text("Inherited from clip")
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    } else {
                        FlowLine(labels: step.lockedFieldLabels, color: AppColors.lockAccent)
                    }
                }
                .padding(.top, 4)
            }
        }
        .frame(width: 250, alignment: .topLeading)
        .padding(12)
        .background(AppColors.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct InspectorRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(AppColors.secondaryText)
            Spacer()
            Text(value)
                .font(.body.monospacedDigit().weight(.medium))
        }
        .font(.subheadline)
    }
}

private struct RulePanel: View {
    let title: String
    let rows: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PanelHeader(title: title, detail: "\(rows.count)")

            ForEach(rows.prefix(5), id: \.self) { row in
                Text(row)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(12)
        .background(AppColors.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct TransformPlaceholder: View {
    let scaleSummary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PanelHeader(title: "Clip Ops", detail: scaleSummary)

            let actions = ["Dup", "Del", "+1", "-1", "Oct", "Rot", "Rev", "Qtz"]
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(46), spacing: 6), count: 4), spacing: 6) {
                ForEach(actions, id: \.self) { action in
                    Text(action)
                        .font(.caption.weight(.semibold))
                        .frame(width: 46, height: 30)
                        .background(AppColors.panelAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .frame(width: 230, alignment: .topLeading)
        .padding(12)
        .background(AppColors.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct EventLog: View {
    let rows: [RenderedEventRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PanelHeader(title: "Rendered Clip Event Log", detail: "\(rows.count) events")

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                GridRow {
                    LogHeader("Beat")
                    LogHeader("Kind")
                    LogHeader("Detail")
                    LogHeader("Ch")
                }

                ForEach(rows.prefix(12)) { row in
                    GridRow {
                        Text(formatBeat(row.beat)).monospacedDigit()
                        Text(row.kind)
                        Text(row.detail)
                        Text("\(row.channel)").monospacedDigit()
                    }
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
        .padding(12)
        .background(AppColors.panel)
    }
}

private struct LogHeader: View {
    let value: String

    init(_ value: String) {
        self.value = value
    }

    var body: some View {
        Text(value.uppercased())
            .font(.caption2.weight(.bold))
            .foregroundStyle(AppColors.primaryText)
    }
}

private struct PanelHeader: View {
    let title: String
    let detail: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text(detail)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
        }
    }
}

private struct MiniBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .background(color.opacity(0.16))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

private struct FlowLine: View {
    let labels: [String]
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            ForEach(labels, id: \.self) { label in
                MiniBadge(text: label, color: color)
            }
        }
    }
}

private func formatBeat(_ value: Double) -> String {
    String(format: "%.2f", value)
}
