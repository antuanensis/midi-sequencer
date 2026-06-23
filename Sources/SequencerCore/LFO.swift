import Foundation
import MidiCore

public struct ClipLFO: Codable, Equatable, Sendable {
    public var id: String
    public var destination: LFODestination
    public var shape: LFOShape
    public var rateCyclesPerBeat: Double
    public var phaseOffset: Double
    public var amplitude: Double
    public var offset: Double

    public init(
        id: String,
        destination: LFODestination,
        shape: LFOShape = .sine,
        rateCyclesPerBeat: Double = 1,
        phaseOffset: Double = 0,
        amplitude: Double = 1,
        offset: Double = 0
    ) {
        self.id = id
        self.destination = destination
        self.shape = shape
        self.rateCyclesPerBeat = rateCyclesPerBeat
        self.phaseOffset = phaseOffset
        self.amplitude = amplitude
        self.offset = offset
    }

    public func value(at beat: Double) -> Double {
        offset + shape.value(phase: beat * rateCyclesPerBeat + phaseOffset) * amplitude
    }
}

public enum LFODestination: Codable, Equatable, Sendable {
    case cc(controller: Int)
    case probability
}

public enum LFOShape: String, Codable, Equatable, Sendable {
    case sine
    case triangle
    case square

    public func value(phase: Double) -> Double {
        let normalized = phase - floor(phase)

        switch self {
        case .sine:
            return sin(normalized * 2 * .pi)
        case .triangle:
            if normalized < 0.25 {
                return normalized * 4
            }
            if normalized < 0.75 {
                return 2 - normalized * 4
            }
            return normalized * 4 - 4
        case .square:
            return normalized < 0.5 ? 1 : -1
        }
    }
}
