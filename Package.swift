// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NiceNotifications",
    platforms: [
        .iOS(.v10),
        .watchOS(.v3),
        .macOS(.v10_14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NiceNotifications",
            targets: ["NiceNotifications"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/nicephoton/DateBuilder", from: "0.0.5"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NiceNotifications",
            dependencies: ["DateBuilder"]),
        .testTarget(
            name: "NiceNotificationsTests",
            dependencies: ["NiceNotifications"]),
    ]
)
