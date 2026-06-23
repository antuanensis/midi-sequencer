public struct MIDIChannel: Codable, Equatable, Hashable, Sendable {
    public let value: Int

    public init(_ value: Int) {
        precondition((1...16).contains(value), "MIDI channel must be 1...16")
        self.value = value
    }
}

public enum MIDIEvent: Codable, Equatable, Sendable {
    case noteOn(note: Int, velocity: Int, channel: MIDIChannel)
    case noteOff(note: Int, velocity: Int, channel: MIDIChannel)
    case controlChange(controller: Int, value: Int, channel: MIDIChannel)
}

public struct ScheduledMIDIEvent: Codable, Equatable, Sendable {
    public let beat: Double
    public let event: MIDIEvent

    public init(beat: Double, event: MIDIEvent) {
        self.beat = beat
        self.event = event
    }
}

public enum MIDIValue {
    public static func clampNote(_ value: Int) -> Int {
        min(127, max(0, value))
    }

    public static func clampSevenBit(_ value: Int) -> Int {
        min(127, max(0, value))
    }
}

public struct SeededRandom: Sendable {
    private var state: UInt64

    public init(seed: UInt64) {
        self.state = seed == 0 ? 0x4d595351 : seed
    }

    public mutating func nextUnit() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 11) / 9_007_199_254_740_992.0
    }
}
