import MidiCore
import TheoryEngine

public struct SequencerProject: Codable, Equatable, Sendable {
    public var schemaVersion: ProjectSchemaVersion
    public var id: String
    public var name: String
    public var tracks: [SequencerTrack]
    public var clips: [MIDIClip]
    public var defaultScale: Scale
    public var transformHistory: [ClipTransformCommand]

    public init(
        schemaVersion: ProjectSchemaVersion = .current,
        id: String = "project-1",
        name: String = "Untitled Project",
        tracks: [SequencerTrack] = [SequencerTrack()],
        clips: [MIDIClip] = [MIDIClip()],
        defaultScale: Scale = Scale(rootPitchClass: 0, mode: .chromatic),
        transformHistory: [ClipTransformCommand] = []
    ) {
        self.schemaVersion = schemaVersion
        self.id = id
        self.name = name
        self.tracks = tracks
        self.clips = clips
        self.defaultScale = defaultScale
        self.transformHistory = transformHistory
    }

    public func clip(id: String) -> MIDIClip? {
        clips.first { $0.id == id }
    }
}

public struct ProjectSchemaVersion: Codable, Equatable, Comparable, Sendable {
    public static let current = ProjectSchemaVersion(major: 1, minor: 0, patch: 0)

    public var major: Int
    public var minor: Int
    public var patch: Int

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public static func < (lhs: ProjectSchemaVersion, rhs: ProjectSchemaVersion) -> Bool {
        [lhs.major, lhs.minor, lhs.patch].lexicographicallyPrecedes([rhs.major, rhs.minor, rhs.patch])
    }
}

public struct SequencerTrack: Codable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var midiChannel: MIDIChannel
    public var clipIDs: [String]
    public var activeClipID: String?
    public var isMuted: Bool

    public init(
        id: String = "track-1",
        name: String = "Track 1",
        midiChannel: MIDIChannel = MIDIChannel(1),
        clipIDs: [String] = ["clip-1"],
        activeClipID: String? = "clip-1",
        isMuted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.midiChannel = midiChannel
        self.clipIDs = clipIDs
        self.activeClipID = activeClipID
        self.isMuted = isMuted
    }
}

public enum ClipTransformCommand: Codable, Equatable, Sendable {
    case duplicate(sourceClipID: String, newClipID: String)
    case delete(clipID: String)
    case transpose(clipID: String, semitones: Int)
    case octaveShift(clipID: String, octaves: Int)
    case rotate(clipID: String, steps: Int)
    case reverse(clipID: String)
    case quantize(clipID: String, scale: Scale)
}
