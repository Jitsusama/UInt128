// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UInt128",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "UInt128",
            targets: ["UInt128"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "UInt128",
            dependencies: []),
        .testTarget(
            name: "UInt128Tests",
            dependencies: ["UInt128"],
            path: "Tests"
        )
    ]
)
