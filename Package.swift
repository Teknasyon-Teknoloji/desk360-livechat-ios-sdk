// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Desk360LiveChat",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "Desk360LiveChat",
            targets: ["Desk360LiveChat"]
        ),
    ],
    dependencies: [

        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/Teknasyon-Teknoloji/PersistenceKit.git", .branch("master")),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git")
    ],
    targets: [
        .target(
            name: "Desk360LiveChat",
            dependencies: [
                 "PersistenceKit", "Alamofire", "NVActivityIndicatorView", "Kingfisher",
                 .product(name: "FirebaseAuth", package: "Firebase"),
                 .product(name: "Database", package: "Firebase")

          ],
            path: "Sources"
        ),
        .testTarget(
            name: "Desk360LiveChatTests",
            dependencies: ["Desk360LiveChat"],
            path: "Tests"
        ),
    ]
)
