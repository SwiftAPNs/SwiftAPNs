// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftAPNs",
    products: [
        .library(
            name: "SwiftAPNs",
            targets: ["SwiftAPNs"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftAPNs/COpenSSL.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftAPNs",
            dependencies: ["COpenSSL"]),
        .testTarget(
            name: "SwiftAPNsTests",
            dependencies: ["SwiftAPNs"]),
    ]
)
