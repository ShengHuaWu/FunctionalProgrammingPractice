// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "libra-server",
    dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),
    .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
    .package(url: "https://github.com/vapor/auth.git", from: "2.0.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
