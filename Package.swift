// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "PEG",
    products: [
        .library(
            name: "PEG",
            targets: ["PEG"]),
    ],
    targets: [
        .target(
            name: "PEG",
            dependencies: []),
        .testTarget(
            name: "PEGTests",
            dependencies: ["PEG"]),
    ]
)
