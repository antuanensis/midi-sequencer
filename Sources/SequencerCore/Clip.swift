import LockEngine
import MidiCore

public struct ClipStep: Codable, Equatable, Sendable {
    public var note: Int
    public var velocity: Int
    public var gateLengthBeats: Double
    public var probability: Double
    public var octave: Int
    public var ccValues: [Int: Int]

    public init(
        note: Int = 60,
        velocity: Int = 100,
        gateLengthBeats: Double = 0.20,
        probability: Double = 1,
        octave: Int = 0,
        ccValues: [Int: Int] = [:]
    ) {
        self.note = MIDIValue.clampNote(note)
        self.velocity = MIDIValue.clampSevenBit(velocity)
        self.gateLengthBeats = max(0, gateLengthBeats)
        self.probability = min(1, max(0, probability))
        self.octave = octave
        self.ccValues = ccValues
    }

    public func applying(lock: StepLock?) -> ClipStep {
        guard let lock else { return self }

        var copy = self
        if let note = lock.note { copy.note = MIDIValue.clampNote(note) }
        if let velocity = lock.velocity { copy.velocity = MIDIValue.clampSevenBit(velocity) }
        if let gate = lock.gateLengthBeats { copy.gateLengthBeats = max(0, gate) }
        if let probability = lock.probability { copy.probability = min(1, max(0, probability)) }
        if let octave = lock.octave { copy.octave = octave }
        copy.ccValues.merge(lock.ccValues) { _, new in new }
        return copy
    }
}

public struct MIDIClip: Codable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var steps: [ClipStep]
    public var stepLocks: [Int: StepLock]
    public var pitchBehaviorMap: PitchBehaviorMap
    public var lfos: [ClipLFO]
    public var beatsPerStep: Double

    public init(
        id: String = "clip-1",
        name: String = "Clip 1",
        steps: [ClipStep] = Array(repeating: ClipStep(), count: 16),
        stepLocks: [Int: StepLock] = [:],
        pitchBehaviorMap: PitchBehaviorMap = PitchBehaviorMap(),
        lfos: [ClipLFO] = [],
        beatsPerStep: Double = 0.25
    ) {
        precondition(!steps.isEmpty, "A clip must contain at least one step")
        self.id = id
        self.name = name
        self.steps = steps
        self.stepLocks = stepLocks
        self.pitchBehaviorMap = pitchBehaviorMap
        self.lfos = lfos
        self.beatsPerStep = beatsPerStep
    }

    public var lengthBeats: Double {
        Double(steps.count) * beatsPerStep
    }

    public func resolvedStep(at index: Int) -> ClipStep {
        let wrapped = ((index % steps.count) + steps.count) % steps.count
        return steps[wrapped].applying(lock: stepLocks[wrapped])
    }
}
