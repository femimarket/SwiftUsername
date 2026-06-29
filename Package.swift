// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Username",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
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
            path: "Username",
            exclude: ["UsernameApp.swift", "Assets.xcassets"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
