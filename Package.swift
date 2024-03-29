// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Desk360LiveChat",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14)
    ],
    products: [
        .library(
            name: "Desk360LiveChat",
            targets: ["Desk360LiveChat"]
        ),
    ],
    dependencies: [
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", .exact("8.15.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .exact("5.0.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/Teknasyon-Teknoloji/PersistenceKit.git", .branch("master")),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", .upToNextMajor(from: "5.1.0"))
    ],
    targets: [
        .target(
            name: "Desk360LiveChat",
            dependencies: [
                 "PersistenceKit", "Alamofire", "NVActivityIndicatorView", "Kingfisher",
                 .product(name: "FirebaseAuth", package: "Firebase"),
                 .product(name: "FirebaseDatabase", package: "Firebase")

          ],
            path: "Sources",
            resources: [.process("Assets/Desk360LiveChatAssets.bundle")]
        ),
        .testTarget(
            name: "Desk360LiveChatTests",
            dependencies: ["Desk360LiveChat"],
            path: "Tests"
        ),
    ]
)
