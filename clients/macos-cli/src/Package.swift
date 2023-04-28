// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CLITool",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "CLITool", targets: ["CLITool"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .executableTarget(
            name: "CLITool",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                "Rainbow"
            ],
            path: "Sources"
        )
    ]
)