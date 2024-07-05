// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Memorizing",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "AuthClient", targets: ["AuthClient"]),
        .library(name: "AuthClientLive", targets: ["AuthClientLive"]),
        .library(name: "CommonUI", targets: ["CommonUI"]),
        .library(name: "Extensions", targets: ["Extensions"]),
        .library(name: "LoginFeature", targets: ["LoginFeature"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "NoteClient", targets: ["NoteClient"]),
        .library(name: "NoteClientLive", targets: ["NoteClientLive"]),
        .library(name: "Shared", targets: ["Shared"]),
        .library(name: "StudyFeature", targets: ["StudyFeature"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.28.1"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.1.0"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.22.3"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.11.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.3.1"),
        .package(url: "https://github.com/exyte/PopupView", from: "3.0.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AuthClient",
            dependencies: [
                "Models",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "AuthClientLive",
            dependencies: [
                "AuthClient",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
                .product(name: "KakaoSDKAuth", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKUser", package: "kakao-ios-sdk"),
            ]
        ),
        .target(
            name: "CommonUI",
            dependencies: [
                .product(name: "PopupView", package: "PopupView"),
            ]
        ),
        .target(name: "Extensions"),
        .target(
            name: "LoginFeature",
            dependencies: [
                "AuthClient",
                "CommonUI",
                "Shared",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "LoginFeatureTest",
            dependencies: [
                "LoginFeature",
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                "CommonUI",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .testTarget(name: "MemorizingTests"),
        .target(
            name: "NoteClient",
            dependencies: [
                "Models",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "NoteClientLive",
            dependencies: [
                "NoteClient",
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            ]
        ),
        .target(
            name: "Shared",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Models",
            ]
        ),
        .target(
            name: "StudyFeature",
            dependencies: [
                "CommonUI",
                "NoteClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
