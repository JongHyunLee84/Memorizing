// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Target Names**
let AddMarketFeature = "AddMarketFeature"
let AddNoteFeature = "AddNoteFeature"
let AuthClient = "AuthClient"
let AuthClientLive = "AuthClientLive"
let CommonUI = "CommonUI"
let EditProfileFeature = "EditProfileFeature"
let LoginFeature = "LoginFeature"
let MarketClient = "MarketClient"
let MarketClientLive = "MarketClientLive"
let MarketFeature = "MarketFeature"
let MarketNoteDetailFeature = "MarketNoteDetailFeature"
let Models = "Models"
let MyNoteFeature = "MyNoteFeature"
let MyReviewClient = "MyReviewClient"
let MyReviewClientLive = "MyReviewClientLive"
let NoteClient = "NoteClient"
let NoteClientLive = "NoteClientLive"
let ProfileFeature = "ProfileFeature"
let PurchaseHistoryFeature = "PurchaseHistoryFeature"
let ReviewClient = "ReviewClient"
let ReviewClientLive = "ReviewClientLive"
let ReviewHistoryFeature = "ReviewHistoryFeature"
let Shared = "Shared"
let StudyFeature = "StudyFeature"
let URLClient = "URLClient"
let URLClientLive = "URLClientLive"
let Utilities = "Utilities"
let WriteReviewFeature = "WriteReviewFeature"

// MARK: - Target Dependencies**
let AddMarketFeatureTarget: Target.Dependency = .target(name: AddMarketFeature)
let AddNoteFeatureTarget: Target.Dependency = .target(name: AddNoteFeature)
let AuthClientLiveTarget: Target.Dependency = .target(name: AuthClientLive)
let AuthClientTarget: Target.Dependency = .target(name: AuthClient)
let CommonUITarget: Target.Dependency = .target(name: CommonUI)
let EditProfileFeatureTarget: Target.Dependency = .target(name: EditProfileFeature)
let LoginFeatureTarget: Target.Dependency = .target(name: LoginFeature)
let MarketClientLiveTarget: Target.Dependency = .target(name: MarketClientLive)
let MarketClientTarget: Target.Dependency = .target(name: MarketClient)
let MarketFeatureTarget: Target.Dependency = .target(name: MarketFeature)
let MarketNoteDetailFeatureTarget: Target.Dependency = .target(name: MarketNoteDetailFeature)
let ModelsTarget: Target.Dependency = .target(name: Models)
let MyNoteFeatureTarget: Target.Dependency = .target(name: MyNoteFeature)
let MyReviewClientLiveTarget: Target.Dependency = .target(name: MyReviewClientLive)
let MyReviewClientTarget: Target.Dependency = .target(name: MyReviewClient)
let NoteClientLiveTarget: Target.Dependency = .target(name: NoteClientLive)
let NoteClientTarget: Target.Dependency = .target(name: NoteClient)
let ProfileFeatureTarget: Target.Dependency = .target(name: ProfileFeature)
let PurchaseHistoryFeatureTarget: Target.Dependency = .target(name: PurchaseHistoryFeature)
let ReviewClientLiveTarget: Target.Dependency = .target(name: ReviewClientLive)
let ReviewClientTarget: Target.Dependency = .target(name: ReviewClient)
let ReviewHistoryFeatureTarget: Target.Dependency = .target(name: ReviewHistoryFeature)
let SharedTarget: Target.Dependency = .target(name: Shared)
let StudyFeatureTarget: Target.Dependency = .target(name: StudyFeature)
let URLClientTarget: Target.Dependency = .target(name: URLClient)
let URLClientLiveTarget: Target.Dependency = .target(name: URLClientLive)
let UtilitiesTarget: Target.Dependency = .target(name: Utilities)
let WriteReviewFeatureTarget: Target.Dependency = .target(name: WriteReviewFeature)


// MARK: - External Package Names
let FirebaseIOSSDK = "firebase-ios-sdk"
let GoogleSignInIOS = "GoogleSignIn-iOS"
let KakaoIOSSDK = "kakao-ios-sdk"
let PopupViewPackage = "PopupView"
let SwiftComposableArchitecture = "swift-composable-architecture"
let SwiftDependencies = "swift-dependencies"

// MARK: - External Product Dependencies
let ComposableArchitectureProduct: Target.Dependency = .product(name: "ComposableArchitecture", package: SwiftComposableArchitecture)
let DependenciesProduct: Target.Dependency = .product(name: "Dependencies", package: SwiftDependencies)
let DependenciesMacrosProduct: Target.Dependency = .product(name: "DependenciesMacros", package: SwiftDependencies)
let FirebaseAuthProduct: Target.Dependency = .product(name: "FirebaseAuth", package: FirebaseIOSSDK)
let FirebaseFirestoreProduct: Target.Dependency = .product(name: "FirebaseFirestore", package: FirebaseIOSSDK)
let GoogleSignInProduct: Target.Dependency = .product(name: "GoogleSignIn", package: GoogleSignInIOS)
let GoogleSignInSwiftProduct: Target.Dependency = .product(name: "GoogleSignInSwift", package: GoogleSignInIOS)
let KakaoSDKAuthProduct: Target.Dependency = .product(name: "KakaoSDKAuth", package: KakaoIOSSDK)
let KakaoSDKUserProduct: Target.Dependency = .product(name: "KakaoSDKUser", package: KakaoIOSSDK)
let KakaoSDKTalkProduct: Target.Dependency = .product(name: "KakaoSDKTalk", package: KakaoIOSSDK)
let PopupViewProduct: Target.Dependency = .product(name: "PopupView", package: PopupViewPackage)


let package = Package(
    name: "Memorizing",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: AddNoteFeature, targets: [AddNoteFeature]),
        .library(name: AddMarketFeature, targets: [AddMarketFeature]),
        .library(name: AuthClient, targets: [AuthClient]),
        .library(name: AuthClientLive, targets: [AuthClientLive]),
        .library(name: CommonUI, targets: [CommonUI]),
        .library(name: EditProfileFeature, targets: [EditProfileFeature]),
        .library(name: LoginFeature, targets: [LoginFeature]),
        .library(name: Models, targets: [Models]),
        .library(name: MyNoteFeature, targets: [MyNoteFeature]),
        .library(name: MyReviewClient, targets: [MyReviewClient]),
        .library(name: MyReviewClientLive, targets: [MyReviewClientLive]),
        .library(name: MarketFeature, targets: [MarketFeature]),
        .library(name: MarketNoteDetailFeature, targets: [MarketNoteDetailFeature]),
        .library(name: MarketClient, targets: [MarketClient]),
        .library(name: MarketClientLive, targets: [MarketClientLive]),
        .library(name: NoteClient, targets: [NoteClient]),
        .library(name: NoteClientLive, targets: [NoteClientLive]),
        .library(name: ProfileFeature, targets: [ProfileFeature]),
        .library(name: PurchaseHistoryFeature, targets: [PurchaseHistoryFeature]),
        .library(name: ReviewClient, targets: [ReviewClient]),
        .library(name: ReviewClientLive, targets: [ReviewClientLive]),
        .library(name: ReviewHistoryFeature, targets: [ReviewHistoryFeature]),
        .library(name: Shared, targets: [Shared]),
        .library(name: StudyFeature, targets: [StudyFeature]),
        .library(name: URLClient, targets: [URLClient]),
        .library(name: URLClientLive, targets: [URLClientLive]),
        .library(name: Utilities, targets: [Utilities]),
        .library(name: WriteReviewFeature, targets: [WriteReviewFeature]),
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
            name: AddNoteFeature,
            dependencies: [
                CommonUITarget,
                SharedTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: AddMarketFeature,
            dependencies: [
                CommonUITarget,
                MarketClientTarget,
                SharedTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: AuthClient,
            dependencies: [
                ModelsTarget,
                DependenciesProduct,
                DependenciesMacrosProduct,
            ]
        ),
        .target(
            name: AuthClientLive,
            dependencies: [
                AuthClientTarget,
                FirebaseAuthProduct,
                FirebaseFirestoreProduct,
                GoogleSignInProduct,
                GoogleSignInSwiftProduct,
                KakaoSDKAuthProduct,
                KakaoSDKUserProduct,
            ]
        ),
        .target(
            name: CommonUI,
            dependencies: [
                ModelsTarget,
                ComposableArchitectureProduct,
                PopupViewProduct,
            ]
        ),
        .target(
            name: EditProfileFeature,
            dependencies: [
                AuthClientTarget,
                CommonUITarget,
                SharedTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: LoginFeature,
            dependencies: [
                AuthClientTarget,
                CommonUITarget,
                SharedTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: Models,
            dependencies: [
                UtilitiesTarget,
                DependenciesProduct,
            ]
        ),
        .target(
            name: MyNoteFeature,
            dependencies: [
                AddNoteFeatureTarget,
                CommonUITarget,
                NoteClientTarget,
                StudyFeatureTarget,
                SharedTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: MyReviewClient,
            dependencies: [
                ModelsTarget,
                DependenciesProduct,
                DependenciesMacrosProduct,
            ]
        ),
        .target(
            name: MyReviewClientLive,
            dependencies: [
                MyReviewClientTarget,
                FirebaseFirestoreProduct,
            ]
        ),
        .target(
            name: MarketFeature,
            dependencies: [
                AddMarketFeatureTarget,
                CommonUITarget,
                MarketClientTarget,
                MarketNoteDetailFeatureTarget,
                SharedTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: MarketNoteDetailFeature,
            dependencies: [
                CommonUITarget,
                MarketClientTarget,
                ReviewClientTarget,
                SharedTarget,
                UtilitiesTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: MarketClient,
            dependencies: [
                ModelsTarget,
                DependenciesProduct,
                DependenciesMacrosProduct,
            ]
        ),
        .target(
            name: MarketClientLive,
            dependencies: [
                UtilitiesTarget,
                MarketClientTarget,
                FirebaseFirestoreProduct,
            ]
        ),
        .target(
            name: NoteClient,
            dependencies: [
                ModelsTarget,
                DependenciesProduct,
                DependenciesMacrosProduct,
            ]
        ),
        .target(
            name: NoteClientLive,
            dependencies: [
                UtilitiesTarget,
                NoteClientTarget,
                FirebaseFirestoreProduct,
            ]
        ),
        .target(
            name: ProfileFeature,
            dependencies: [
                AuthClientTarget,
                CommonUITarget,
                ComposableArchitectureProduct,
                EditProfileFeatureTarget,
                NoteClientTarget,
                PurchaseHistoryFeatureTarget,
                ReviewHistoryFeatureTarget,
                SharedTarget,
                URLClientTarget,
                WriteReviewFeatureTarget,
            ]
        ),
        .target(
            name: PurchaseHistoryFeature,
            dependencies: [
                CommonUITarget,
                MyReviewClientTarget,
                MarketClientTarget,
                SharedTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: ReviewClient,
            dependencies: [
                ModelsTarget,
                DependenciesProduct,
                DependenciesMacrosProduct,
            ]
        ),
        .target(
            name: ReviewClientLive,
            dependencies: [
                ReviewClientTarget,
                FirebaseFirestoreProduct,
            ]
        ),
        .target(
            name: ReviewHistoryFeature,
            dependencies: [
                CommonUITarget,
                MyReviewClientTarget,
                ReviewClientTarget,
                SharedTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: Shared,
            dependencies: [
                ComposableArchitectureProduct,
                ModelsTarget,
            ]
        ),
        .target(
            name: StudyFeature,
            dependencies: [
                CommonUITarget,
                UtilitiesTarget,
                ComposableArchitectureProduct,
            ]
        ),
        .target(
            name: URLClient,
            dependencies: [
                DependenciesProduct,
                DependenciesMacrosProduct,
                KakaoSDKTalkProduct,
            ]
        ),
        .target(
            name: URLClientLive,
            dependencies: [
                URLClientTarget,
                KakaoSDKTalkProduct,
            ],
            exclude: [
                "Secrets/secrets.json.sample"
            ],
            resources: [
                .copy("Secrets/secrets.json"),
            ]
        ),
        .target(name: Utilities,
                dependencies: [
                    DependenciesProduct,
                ]
               ),
        .target(
            name: WriteReviewFeature,
            dependencies: [
                CommonUITarget,
                ComposableArchitectureProduct,
                MyReviewClientTarget,
                ReviewClientTarget,
                SharedTarget,
            ]
        ),
        // MARK: - Test Target
        .testTarget(
            name: "AddMarketFeatureTest",
            dependencies: [
                AddMarketFeatureTarget,
            ]
        ),
        .testTarget(
            name: "AddNoteFeatureTest",
            dependencies: [
                AddNoteFeatureTarget,
            ]
        ),
        .testTarget(
            name: "EditProfileFeatureTest",
            dependencies: [
                EditProfileFeatureTarget,
            ]
        ),
        .testTarget(
            name: "LoginFeatureTest",
            dependencies: [
                LoginFeatureTarget,
            ]
        ),
        .testTarget(
            name: "MyNoteFeatureTest",
            dependencies: [
                UtilitiesTarget,
                MyNoteFeatureTarget,
            ]
        ),
        .testTarget(
            name: "MarketFeatureTest",
            dependencies: [
                MarketFeatureTarget,
            ]
        ),
        .testTarget(
            name: "MarketNoteDetailFeatureTest",
            dependencies: [
                MarketNoteDetailFeatureTarget,
            ]
        ),
        .testTarget(
            name: "ProfileFeatureTest",
            dependencies: [
                ProfileFeatureTarget,
            ]
        ),
        .testTarget(
            name: "PurchaseHistoryFeatureTest",
            dependencies: [
                PurchaseHistoryFeatureTarget,
            ]
        ),
        .testTarget(
            name: "ReviewHistoryFeatureTest",
            dependencies: [
                ReviewHistoryFeatureTarget,
            ]
        ),
        .testTarget(
            name: "StudyFeatureTest",
            dependencies: [
                StudyFeatureTarget,
            ]
        ),
        .testTarget(
            name: "WriteReviewFeatureTest",
            dependencies: [
                WriteReviewFeatureTarget,
            ]
        ),
    ]
)
