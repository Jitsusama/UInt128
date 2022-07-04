// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "UInt128",
    products: [
        .library(name: "UInt128", targets: ["UInt128"]),
    ],
    targets: [
        .target(name: "UInt128"),
        .testTarget(name: "UInt128Tests", dependencies: ["UInt128"]),
    ]
)
