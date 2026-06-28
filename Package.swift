// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Username",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Username",
            targets: ["Username"]
        ),
    ],
    targets: [
        .target(
            name: "Username",
            path: "Username"
        ),
    ],
    swiftLanguageModes: [.v6]
)
