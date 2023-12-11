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
        .target(
            name: "FoodList",
            dependencies: [
                "FoodDetails",
                "FoodComparison",
                "Shared",
                "API",
                "Database",
                "UserDefaults",
                "Ads",
                tcaDependency,
            ]
        ),
        .target(
            name: "FoodDetails",
            dependencies: [
                "Shared",
                tcaDependency,
            ]
        ),
        .target(
            name: "FoodComparison",
            dependencies: [
                "Shared",
                tcaDependency,
            ]
        ),
        .target(
            name: "UserDefaults",
            dependencies: [
                "Shared",
                tcaDIDependency,
                tcaDIMacroDependency,
            ]
        ),
        .target(
            name: "API",
            dependencies: [
                "Shared",
                tcaDIDependency,
                tcaDIMacroDependency,
            ]
        ),
        .target(
            name: "Database",
            dependencies: [
                "Shared",
                grdbDependency,
                tcaDIDependency,
                tcaDIMacroDependency,
            ]
        ),
        .target(
            name: "Ads",
            dependencies: [
                "Shared",
                billboardDependency,
                tcaDIDependency,
                tcaDIMacroDependency,
            ]
        ),
        .target(
            name: "Spotlight",
            dependencies: [
                "Shared",
                tcaDIDependency,
                tcaDIMacroDependency,
            ]
        ),
        .target(
            name: "Shared",
            dependencies: [
                tcaDIDependency,
                tcaDIMacroDependency,
            ]
        ),
        .testTarget(
            name: "FoodComparisonTests",
            dependencies: [
                "FoodComparison",
                "Shared"
            ]
        ),
        .testTarget(
            name: "FoodListTests",
            dependencies: [
                "FoodList",
                "Shared",
                "Ads",
                "API",
                "Spotlight"
            ]
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        ),
    ]
)

extension Product {
    static func library(name: String, type: PackageDescription.Product.Library.LibraryType? = nil) -> PackageDescription.Product {
        .library(name: name, type: type, targets: [name])
    }
}
