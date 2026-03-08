// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MacAppPlay",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(
            name: "mac_app_play",
            targets: [
                "mac_app_play"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
    ],
    targets: [
        .executableTarget(
            name: "mac_app_play",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
