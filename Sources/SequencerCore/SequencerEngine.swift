import LockEngine
import MidiCore

public struct SequencerEngine: Sendable {
    public init() {}

    public func render(clip: MIDIClip, loops: Int = 1, seed: UInt64 = 1, channel: MIDIChannel = MIDIChannel(1)) -> [ScheduledMIDIEvent] {
        guard loops > 0 else { return [] }

        var random = SeededRandom(seed: seed)
        var events: [ScheduledMIDIEvent] = []

        for loop in 0..<loops {
            for index in clip.steps.indices {
                let step = clip.resolvedStep(at: index)
                let baseNote = MIDIValue.clampNote(step.note + (step.octave * 12))
                let behavior = clip.pitchBehaviorMap.behavior(for: baseNote)
                let probability = min(1, max(0, step.probability * behavior.probabilityMultiplier))

                guard random.nextUnit() <= probability else { continue }

                let beat = Double(loop) * clip.lengthBeats + Double(index) * clip.beatsPerStep
                let outputChannel = behavior.outputChannel ?? channel
                let outputNote = MIDIValue.clampNote(baseNote + behavior.transposeOctaves * 12)
                let velocity = MIDIValue.clampSevenBit(step.velocity)
                let noteOffBeat = beat + step.gateLengthBeats

                var ccValues = step.ccValues
                ccValues.merge(behavior.ccValues) { _, new in new }
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
            }
        }

        return events.sorted { lhs, rhs in
            if lhs.beat == rhs.beat {
                return eventSortKey(lhs.event) < eventSortKey(rhs.event)
            }
            return lhs.beat < rhs.beat
        }
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
