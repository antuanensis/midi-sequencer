// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MidiSequencer",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MidiCore", targets: ["MidiCore"]),
        .library(name: "LockEngine", targets: ["LockEngine"]),
        .library(name: "TheoryEngine", targets: ["TheoryEngine"]),
        .library(name: "SequencerCore", targets: ["SequencerCore"]),
        .library(name: "TransformEngine", targets: ["TransformEngine"]),
        .library(name: "AppUI", targets: ["AppUI"]),
        .executable(name: "MidiSequencerDebugApp", targets: ["MidiSequencerDebugApp"])
    ],
    targets: [
        .target(name: "MidiCore"),
        .target(name: "LockEngine", dependencies: ["MidiCore"]),
        .target(name: "TheoryEngine", dependencies: ["MidiCore"]),
        .target(name: "SequencerCore", dependencies: ["MidiCore", "LockEngine", "TheoryEngine"]),
        .target(name: "TransformEngine", dependencies: ["MidiCore", "SequencerCore", "TheoryEngine"]),
        .target(name: "AppUI", dependencies: ["MidiCore", "LockEngine", "SequencerCore", "TheoryEngine"]),
        .executableTarget(name: "MidiSequencerDebugApp", dependencies: ["AppUI"]),
        .testTarget(name: "SequencerCoreTests", dependencies: ["MidiCore", "LockEngine", "TheoryEngine", "SequencerCore", "TransformEngine"]),
        .testTarget(name: "AppUITests", dependencies: ["AppUI"])
    ]
)
