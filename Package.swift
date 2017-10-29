// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "PEG",
    products: [
        .library(
            name: "PEG",
            targets: ["PEG"]),
        .executable(
            name: "playground",
            targets: ["playground"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "playground",
            dependencies: ["PEG"]),
        .target(
            name: "PEG",
            dependencies: []),
        .testTarget(
            name: "PEGTests",
            dependencies: ["PEG"]),
    ]
)
