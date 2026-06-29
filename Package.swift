// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "wifiqr",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "wifiqr",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/wifiqr",
            swiftSettings: [
                // The --menu mode runs an AppKit/SwiftUI menu bar agent; v5 mode
                // keeps the GUI callbacks ergonomic without Sendable ceremony.
                .swiftLanguageMode(.v5),
            ],
            linkerSettings: [
                // Embed Info.plist (LSUIElement) so --menu runs as a menu-bar
                // agent with no Dock icon. Harmless for the CLI path.
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Resources/Info.plist",
                ]),
            ]
        ),
    ]
)
