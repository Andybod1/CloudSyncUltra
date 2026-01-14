// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CloudSyncMVP",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "CloudSyncMVP",
            targets: ["CloudSyncMVP"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "CloudSyncMVP",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            path: "Sources"
        )
    ]
)
