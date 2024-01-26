// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tsl-ios-sdk",
    platforms: [
            .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "tsl-ios-sdk",
            targets: ["tsl-ios-sdk"]),
    ],
    dependencies: [
            .package(url: "https://github.com/pubnub/swift.git", from: "6.2.3"),
            // Add other dependencies if needed
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "tsl-ios-sdk",
            dependencies: [
                .product(name: "PubNub", package: "swift")
            ],
            resources: [
                .process("Resources/Keys/env.json"),
                .process("Resources/Keys/Development.json"),
                .process("Resources/Keys/Staging.json"),
                .process("Resources/Keys/Production.json"),

                // Add other resource files as needed
            ]),
        .testTarget(
            name: "tsl-ios-sdkTests",
            dependencies: ["tsl-ios-sdk"]),
    ]
)
