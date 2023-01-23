// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SupaSlack",
  platforms: [.iOS(.v16), .macOS(.v13)],
  products: [
    .library(name: "APIClientLive", targets: ["APIClientLive"]),
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "AuthClientLive", targets: ["AuthClientLive"]),
    .library(name: "AuthFeature", targets: ["AuthFeature"]),
    .library(name: "ChannelsFeature", targets: ["ChannelsFeature"]),
    .library(name: "DatabaseClientLive", targets: ["DatabaseClientLive"]),
    .library(name: "MessagesFeature", targets: ["MessagesFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.0.4"),
    .package(url: "https://github.com/binaryscraping/swiftui-toast", branch: "main"),
    .package(url: "https://github.com/binaryscraping/bs-apple-kit", branch: "main"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.9.0"),
    .package(url: "https://github.com/groue/GRDB.swift", from: "6.6.1"),
    .package(
      url: "https://github.com/supabase-community/supabase-swift",
      branch: "release-candidate"
    ),
  ],
  targets: [
    .target(
      name: "APIClient",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "APIClientLive",
      dependencies: [
        "APIClient",
        "SupabaseDependency",
      ]
    ),
    .target(
      name: "AppFeature",
      dependencies: [
        "AuthFeature",
        "ChannelsFeature",
        "MessagesFeature",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ]
    ),
    .target(
      name: "AuthClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Tagged", package: "swift-tagged"),
      ]
    ),
    .target(
      name: "AuthClientLive",
      dependencies: [
        "AuthClient",
        "SupabaseDependency",
      ]
    ),
    .target(
      name: "AuthFeature",
      dependencies: [
        "AuthClient",
        "Helpers",
        .product(name: "SwiftUIHelpers", package: "bs-apple-kit"),
        .product(name: "ToastUI", package: "swiftui-toast"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "ChannelsFeature",
      dependencies: [
        "APIClient",
        "DatabaseClient",
      ]
    ),
    .target(
      name: "DatabaseClient",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "DatabaseClientLive",
      dependencies: [
        "DatabaseClient",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "GRDB", package: "GRDB.swift"),
      ]
    ),
    .testTarget(
      name: "DatabaseClientLiveTests",
      dependencies: ["DatabaseClientLive"]
    ),
    .target(
      name: "Helpers",
      dependencies: [
        .product(name: "ToastUI", package: "swiftui-toast"),
      ]
    ),
    .target(
      name: "MessagesFeature",
      dependencies: [
        "Models",
        "DatabaseClient",
        "APIClient",
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "Models",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged"),
      ]
    ),
    .target(
      name: "SupabaseDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Supabase", package: "supabase-swift"),
      ]
    ),
  ]
)
