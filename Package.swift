// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PKMApp",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-markdown.git", from: "0.3.0")
    ],
    targets: [
        .executableTarget(
            name: "PKMApp",
            dependencies: [
                "Yams",
                .product(name: "Markdown", package: "swift-markdown")
            ],
            path: "Sources/PKMApp",
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "PKMAppTests",
            dependencies: ["PKMApp"],
            path: "Tests"
        )
    ]
)
