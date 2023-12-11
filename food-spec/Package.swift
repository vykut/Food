// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let grdbDependency: Target.Dependency = .product(name: "GRDB", package: "GRDB.swift")
let billboardDependency: Target.Dependency = .product(name: "Billboard", package: "billboard")
let tcaDependency: Target.Dependency = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let tcaDIDependency: Target.Dependency = .product(name: "Dependencies", package: "swift-dependencies")
let tcaDIMacroDependency: Target.Dependency = .product(name: "DependenciesMacros", package: "swift-dependencies")

let package = Package(
    name: "food-spec",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "FoodList"),
        .library(name: "FoodDetails"),
        .library(name: "FoodComparison"),
        .library(name: "Shared"),
        .library(name: "Database"),
        .library(name: "UserDefaults"),
        .library(name: "Spotlight"),
        .library(name: "API"),
        .library(name: "Ads"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "observation-beta"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.1.2"),
        .package(url: "https://github.com/groue/GRDB.swift", from: "6.23.0"),
        .package(url: "https://github.com/hiddevdploeg/Billboard", from: "1.0.2"),
    ],
    targets: [
        .feature(name: "FoodList", dependencies: ["FoodDetails", "FoodComparison", "API", "Database", "UserDefaults", "Ads", "Spotlight"]),
        .featureTests(for: "FoodList"),
        .feature(name: "FoodDetails"),
        .feature(name: "FoodComparison"),
        .featureTests(for: "FoodComparison"),
        .client(name: "UserDefaults"),
        .client(name: "API"),
        .testTarget(for: "API"),
        .client(name: "Database", dependencies: [grdbDependency]),
        .client(name: "Ads", dependencies: [billboardDependency]),
        .client(name: "Spotlight"),
        .target(name: "Shared"),
        .testTarget(for: "Shared"),
    ]
)

extension Target {
    /// adds `Shared`, `DI` and `DIMacro` as default dependencies
    static func client(name: String, dependencies: [Dependency] = []) -> Target {
        .target(
            name: name,
            dependencies: ["Shared", tcaDIDependency, tcaDIMacroDependency] + dependencies
        )
    }

    /// adds `TCA` as a default dependency
    static func feature(name: String, dependencies: [Dependency] = []) -> Target {
        .target(
            name: name,
            dependencies: ["Shared", tcaDependency] + dependencies
        )
    }
    /// adds `Shared` and `TCA` as default dependencies
    static func featureTests(for feature: String, dependencies: [Dependency] = []) -> Target {
        .testTarget(
            for: feature,
            dependencies: ["Shared"]
        )
    }

    static func testTarget(for target: String, dependencies: [Dependency] = []) -> Target {
        .testTarget(
            name: target+"Tests",
            dependencies: CollectionOfOne(.target(name: target)) + dependencies
        )
    }
}

extension Product {
    static func library(name: String, type: PackageDescription.Product.Library.LibraryType? = nil) -> PackageDescription.Product {
        .library(name: name, type: type, targets: [name])
    }
}
