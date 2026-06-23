import MidiCore

public enum ScaleMode: String, Codable, Equatable, CaseIterable, Sendable {
    case chromatic
    case major
    case naturalMinor
    case dorian
    case mixolydian

    public var intervals: [Int] {
        switch self {
        case .chromatic:
            return Array(0...11)
        case .major:
            return [0, 2, 4, 5, 7, 9, 11]
        case .naturalMinor:
            return [0, 2, 3, 5, 7, 8, 10]
        case .dorian:
            return [0, 2, 3, 5, 7, 9, 10]
        case .mixolydian:
            return [0, 2, 4, 5, 7, 9, 10]
        }
    }
}

public struct Scale: Codable, Equatable, Sendable {
    public var rootPitchClass: Int
    public var mode: ScaleMode

    public init(rootPitchClass: Int, mode: ScaleMode) {
        self.rootPitchClass = ((rootPitchClass % 12) + 12) % 12
        self.mode = mode
    }

    public func contains(note: Int) -> Bool {
        let pitchClass = ((note % 12) + 12) % 12
        return mode.intervals.contains(((pitchClass - rootPitchClass) + 12) % 12)
    }

    public func quantize(note: Int) -> Int {
        if contains(note: note) {
            return MIDIValue.clampNote(note)
        }

        for distance in 1...12 {
            let up = note + distance
            if contains(note: up) {
                return MIDIValue.clampNote(up)
            }

            let down = note - distance
            if contains(note: down) {
                return MIDIValue.clampNote(down)
            }
        }

        return MIDIValue.clampNote(note)
    }
}
