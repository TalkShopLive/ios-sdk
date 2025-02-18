// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Talkshoplive",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Talkshoplive",
            targets: ["Talkshoplive"]),
    ],
    dependencies: [
            .package(url: "https://github.com/pubnub/swift.git", from: "8.2.4"),
            // Add other dependencies if needed
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Talkshoplive",
            dependencies: [
                .product(name: "PubNubSDK", package: "swift")
            ],
            path: "Sources/Talkshoplive",
            resources: [
                // Add other resource files as needed
            ],
            swiftSettings: [
                .define("PLATFORM_IOS")
            ]
        ),
        .testTarget(
            name: "TalkshopliveTests",
            dependencies: ["Talkshoplive"]),
    ],
    swiftLanguageVersions: [.v5]
)
