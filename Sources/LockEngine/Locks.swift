import MidiCore

public struct StepLock: Codable, Equatable, Sendable {
    public var note: Int?
    public var velocity: Int?
    public var gateLengthBeats: Double?
    public var probability: Double?
    public var octave: Int?
    public var ccValues: [Int: Int]

    public init(
        note: Int? = nil,
        velocity: Int? = nil,
        gateLengthBeats: Double? = nil,
        probability: Double? = nil,
        octave: Int? = nil,
        ccValues: [Int: Int] = [:]
    ) {
        self.note = note
        self.velocity = velocity
        self.gateLengthBeats = gateLengthBeats
        self.probability = probability
        self.octave = octave
        self.ccValues = ccValues
    }
}

public enum PitchBehaviorTarget: Codable, Equatable, Hashable, Sendable {
    case pitch(Int)
    case pitchClass(Int)
}

public struct PitchBehavior: Codable, Equatable, Sendable {
    public var ccValues: [Int: Int]
    public var outputChannel: MIDIChannel?
    public var transposeOctaves: Int
    public var probabilityMultiplier: Double
    public var harmonyOffsets: [Int]

    public init(
        ccValues: [Int: Int] = [:],
        outputChannel: MIDIChannel? = nil,
        transposeOctaves: Int = 0,
        probabilityMultiplier: Double = 1,
        harmonyOffsets: [Int] = []
    ) {
        self.ccValues = ccValues
        self.outputChannel = outputChannel
        self.transposeOctaves = transposeOctaves
        self.probabilityMultiplier = probabilityMultiplier
        self.harmonyOffsets = harmonyOffsets
    }
}

public struct PitchBehaviorMap: Codable, Equatable, Sendable {
    public var behaviors: [PitchBehaviorTarget: PitchBehavior]

    public init(_ behaviors: [PitchBehaviorTarget: PitchBehavior] = [:]) {
        self.behaviors = behaviors
    }

    public func behavior(for note: Int) -> PitchBehavior {
        let pitchClass = ((note % 12) + 12) % 12
        var result = behaviors[.pitchClass(pitchClass)] ?? PitchBehavior()

        if let exact = behaviors[.pitch(note)] {
            result.ccValues.merge(exact.ccValues) { _, new in new }
            result.outputChannel = exact.outputChannel ?? result.outputChannel
            result.transposeOctaves += exact.transposeOctaves
            result.probabilityMultiplier *= exact.probabilityMultiplier
            result.harmonyOffsets.append(contentsOf: exact.harmonyOffsets)
        }

        return result
    }
}
