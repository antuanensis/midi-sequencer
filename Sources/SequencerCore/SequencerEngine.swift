import LockEngine
import MidiCore

public struct SequencerEngine: Sendable {
    public init() {}

    public func render(clip: MIDIClip, loops: Int = 1, seed: UInt64 = 1, channel: MIDIChannel = MIDIChannel(1)) -> [ScheduledMIDIEvent] {
        guard loops > 0 else { return [] }

        return render(clip: clip, startBeat: 0, endBeat: Double(loops) * clip.lengthBeats, seed: seed, channel: channel)
    }

    public func render(
        clip: MIDIClip,
        startBeat: Double,
        endBeat: Double,
        seed: UInt64 = 1,
        channel: MIDIChannel = MIDIChannel(1)
    ) -> [ScheduledMIDIEvent] {
        guard endBeat > startBeat, endBeat > 0 else { return [] }

        var random = SeededRandom(seed: seed)
        var events: [ScheduledMIDIEvent] = []
        let firstOutputBeat = max(0, startBeat)
        let lastStepIndex = Int((endBeat / clip.beatsPerStep).rounded(.up)) - 1

        guard lastStepIndex >= 0 else { return [] }

        for absoluteStepIndex in 0...lastStepIndex {
            let stepEvents = renderStep(
                clip: clip,
                absoluteStepIndex: absoluteStepIndex,
                random: &random,
                channel: channel
            )

            for event in stepEvents where event.beat >= firstOutputBeat && event.beat < endBeat {
                events.append(event)
            }
        }

        return events.sorted { lhs, rhs in
            if lhs.beat == rhs.beat {
                return eventSortKey(lhs.event) < eventSortKey(rhs.event)
            }
            return lhs.beat < rhs.beat
        }
    }

    private func renderStep(
        clip: MIDIClip,
        absoluteStepIndex: Int,
        random: inout SeededRandom,
        channel: MIDIChannel
    ) -> [ScheduledMIDIEvent] {
        let step = clip.resolvedStep(at: absoluteStepIndex)
        let baseNote = MIDIValue.clampNote(step.note + (step.octave * 12))
        let behavior = clip.pitchBehaviorMap.behavior(for: baseNote)
        let beat = Double(absoluteStepIndex) * clip.beatsPerStep
        let probabilityModulation = clip.lfos.reduce(0) { partial, lfo in
            guard lfo.destination == .probability else { return partial }
            return partial + lfo.value(at: beat)
        }
        let probability = min(1, max(0, (step.probability + probabilityModulation) * behavior.probabilityMultiplier))

        guard random.nextUnit() <= probability else { return [] }

        let outputChannel = behavior.outputChannel ?? channel
        let outputNote = MIDIValue.clampNote(baseNote + behavior.transposeOctaves * 12)
        let velocity = MIDIValue.clampSevenBit(step.velocity)
        let noteOffBeat = beat + step.gateLengthBeats
        var events: [ScheduledMIDIEvent] = []

        var ccValues = step.ccValues
        ccValues.merge(behavior.ccValues) { _, new in new }
        for lfo in clip.lfos {
            guard case .cc(let controller) = lfo.destination else { continue }
            ccValues[controller] = MIDIValue.clampSevenBit(Int(lfo.value(at: beat).rounded()))
        }
        for controller in ccValues.keys.sorted() {
            guard let value = ccValues[controller] else { continue }
            events.append(ScheduledMIDIEvent(
                beat: beat,
                event: .controlChange(
                    controller: MIDIValue.clampSevenBit(controller),
                    value: MIDIValue.clampSevenBit(value),
                    channel: outputChannel
                )
            ))
        }

        events.append(ScheduledMIDIEvent(beat: beat, event: .noteOn(note: outputNote, velocity: velocity, channel: outputChannel)))
        events.append(ScheduledMIDIEvent(beat: noteOffBeat, event: .noteOff(note: outputNote, velocity: 0, channel: outputChannel)))

        for offset in behavior.harmonyOffsets {
            let harmonyNote = MIDIValue.clampNote(outputNote + offset)
            events.append(ScheduledMIDIEvent(beat: beat, event: .noteOn(note: harmonyNote, velocity: velocity, channel: outputChannel)))
            events.append(ScheduledMIDIEvent(beat: noteOffBeat, event: .noteOff(note: harmonyNote, velocity: 0, channel: outputChannel)))
        }

        return events
    }

    private func eventSortKey(_ event: MIDIEvent) -> Int {
        switch event {
        case .controlChange:
            return 0
        case .noteOn:
            return 1
        case .noteOff:
            return 2
        }
    }
}
