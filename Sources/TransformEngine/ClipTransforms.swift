import MidiCore
import SequencerCore
import TheoryEngine

public enum ClipTransforms {
    public static func duplicate(_ clip: MIDIClip, id: String, name: String? = nil) -> MIDIClip {
        var copy = clip
        copy.id = id
        copy.name = name ?? "\(clip.name) Copy"
        return copy
    }

    public static func transpose(_ clip: MIDIClip, semitones: Int) -> MIDIClip {
        var copy = clip
        copy.steps = copy.steps.map { step in
            var next = step
            next.note = MIDIValue.clampNote(step.note + semitones)
            return next
        }
        return copy
    }

    public static func octaveShift(_ clip: MIDIClip, octaves: Int) -> MIDIClip {
        transpose(clip, semitones: octaves * 12)
    }

    public static func rotate(_ clip: MIDIClip, steps offset: Int) -> MIDIClip {
        guard !clip.steps.isEmpty else { return clip }

        let count = clip.steps.count
        let shift = ((offset % count) + count) % count
        var copy = clip
        copy.steps = Array(clip.steps[(count - shift)..<count] + clip.steps[0..<(count - shift)])
        copy.stepLocks = Dictionary(uniqueKeysWithValues: clip.stepLocks.map { index, lock in
            (((index + shift) % count), lock)
        })
        return copy
    }

    public static func reverse(_ clip: MIDIClip) -> MIDIClip {
        let count = clip.steps.count
        var copy = clip
        copy.steps = clip.steps.reversed()
        copy.stepLocks = Dictionary(uniqueKeysWithValues: clip.stepLocks.map { index, lock in
            ((count - 1 - index), lock)
        })
        return copy
    }

    public static func quantize(_ clip: MIDIClip, to scale: Scale) -> MIDIClip {
        var copy = clip
        copy.steps = copy.steps.map { step in
            var next = step
            next.note = scale.quantize(note: step.note)
            return next
        }
        return copy
    }
}
