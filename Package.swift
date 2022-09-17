// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DependencyMonitor",
    platforms: [
        .macOS(.v10_15), .iOS(.v15)
    ],
    products: [
        .library(
            name: "DependencyMonitor",
            targets: ["DependencyMonitor"]),
    ],
    targets: [
        .binaryTarget(
            name: "DependencyMonitor",
            path: "./Sources/DependencyMonitor.xcframework"),
    ]
)
