// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "FeatureToggleKit",
  platforms: [.iOS(.v15)],
  products: [
    // FeatureToggleKit, FeatureToggleKitImp, FeatureToggleKitMock
    .library(
      name: "FeatureToggleKit",
      targets: ["FeatureToggleKit"]
    ),
    .library(
      name: "FeatureToggleKitImp",
      targets: ["FeatureToggleKitImp"]
    ),
    .library(
      name: "FeatureToggleKitMock",
      targets: ["FeatureToggleKitMock"]
    ),
  ],
  dependencies: [
    // FeatureToggleKit
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk.git",
      .upToNextMinor(from: "12.3.0")
    ),
  ],
  targets: [
    // FeatureToggleKit, FeatureToggleKitImp, FeatureToggleKitMock, FeatureToggleKitImpTests
    .target(
      name: "FeatureToggleKit",
      dependencies: [],
      path: "Sources/FeatureToggleKit/interfaces/src"
    ),
    .target(
      name: "FeatureToggleKitImp",
      dependencies: [
        "FeatureToggleKit",
        .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
      ],
      path: "Sources/FeatureToggleKit/implementation/src"
    ),
    .target(
      name: "FeatureToggleKitMock",
      dependencies: ["FeatureToggleKit"],
      path: "Sources/FeatureToggleKit/mocks/src"
    ),
  ],
  swiftLanguageModes: [.v6]
)
