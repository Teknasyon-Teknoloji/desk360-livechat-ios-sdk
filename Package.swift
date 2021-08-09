// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LiveChat",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "LiveChat",
            targets: ["LiveChat"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LiveChat",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "LiveChatTests",
            dependencies: ["LiveChat"],
            path: "Tests"
        ),
    ]
)
