// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Desk360LiveChat",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "Desk360LiveChat",
            targets: ["Desk360LiveChat"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Desk360LiveChat",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "Desk360LiveChatTests",
            dependencies: ["Desk360LiveChat"],
            path: "Tests"
        ),
    ]
)
