import SequencerCore

public enum ProjectTransformError: Error, Equatable, Sendable {
    case clipNotFound(String)
    case duplicateClipID(String)
}

public extension SequencerProject {
    func applying(_ command: ClipTransformCommand) throws -> SequencerProject {
        var copy = self
        try copy.apply(command)
        return copy
    }

    mutating func apply(_ command: ClipTransformCommand) throws {
        switch command {
        case .duplicate(let sourceClipID, let newClipID):
            try duplicateClip(sourceClipID: sourceClipID, newClipID: newClipID)
        case .delete(let clipID):
            try deleteClip(id: clipID)
        case .transpose(let clipID, let semitones):
            try updateClip(id: clipID) { ClipTransforms.transpose($0, semitones: semitones) }
        case .octaveShift(let clipID, let octaves):
            try updateClip(id: clipID) { ClipTransforms.octaveShift($0, octaves: octaves) }
        case .rotate(let clipID, let steps):
            try updateClip(id: clipID) { ClipTransforms.rotate($0, steps: steps) }
        case .reverse(let clipID):
            try updateClip(id: clipID) { ClipTransforms.reverse($0) }
        case .quantize(let clipID, let scale):
            try updateClip(id: clipID) { ClipTransforms.quantize($0, to: scale) }
        }

        transformHistory.append(command)
    }

    private mutating func duplicateClip(sourceClipID: String, newClipID: String) throws {
        guard !clips.contains(where: { $0.id == newClipID }) else {
            throw ProjectTransformError.duplicateClipID(newClipID)
        }

        guard let source = clips.first(where: { $0.id == sourceClipID }) else {
            throw ProjectTransformError.clipNotFound(sourceClipID)
        }

        let duplicated = ClipTransforms.duplicate(source, id: newClipID)
        clips.append(duplicated)

        tracks = tracks.map { track in
            guard track.clipIDs.contains(sourceClipID) else { return track }

            var next = track
            next.clipIDs.append(newClipID)
            if track.activeClipID == sourceClipID {
                next.activeClipID = newClipID
            }
            return next
        }
    }

    private mutating func deleteClip(id clipID: String) throws {
        guard clips.contains(where: { $0.id == clipID }) else {
            throw ProjectTransformError.clipNotFound(clipID)
        }

        clips.removeAll { $0.id == clipID }
        tracks = tracks.map { track in
            var next = track
            next.clipIDs.removeAll { $0 == clipID }
            if next.activeClipID == clipID {
                next.activeClipID = next.clipIDs.first
            }
            return next
        }
    }

    private mutating func updateClip(id clipID: String, transform: (MIDIClip) -> MIDIClip) throws {
        guard let index = clips.firstIndex(where: { $0.id == clipID }) else {
            throw ProjectTransformError.clipNotFound(clipID)
        }

        clips[index] = transform(clips[index])
    }
}
