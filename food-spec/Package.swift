// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let grdbDependency: Target.Dependency = .product(name: "GRDB", package: "GRDB.swift")
let billboardDependency: Target.Dependency = .product(name: "Billboard", package: "billboard")
let asyncSemaphoreDependency: Target.Dependency = .product(name: "Semaphore", package: "Semaphore")
let tcaDependency: Target.Dependency = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let tcaDIDependency: Target.Dependency = .product(name: "Dependencies", package: "swift-dependencies")
let tcaDIMacroDependency: Target.Dependency = .product(name: "DependenciesMacros", package: "swift-dependencies")

let package = Package(
    name: "food-spec",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "TabBar"),
        .library(name: "FoodList"),
        .library(name: "FoodDetails"),
        .library(name: "FoodSelection"),
        .library(name: "FoodComparison"),
        .library(name: "MealList"),
        .library(name: "MealForm"),
        .library(name: "MealDetails"),
        .library(name: "AddIngredients"),
        .library(name: "IngredientPicker"),
        .library(name: "QuantityPicker"),
        .library(name: "Shared"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "observation-beta"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.1.2"),
        .package(url: "https://github.com/groue/GRDB.swift", from: "6.23.0"),
        .package(url: "https://github.com/hiddevdploeg/Billboard", from: "1.0.2"),
        .package(url: "https://github.com/groue/Semaphore", from: "0.0.8"),
    ],
    targets: [
        .feature(name: "TabBar", dependencies: ["FoodList", "FoodSelection", "MealList"]),
        .feature(name: "FoodList", dependencies: ["FoodDetails", "API", "Database", "UserPreferences", "Ads", "Spotlight"]),
        .feature(name: "FoodDetails", dependencies: ["QuantityPicker"]),
        .feature(name: "FoodSelection", dependencies: ["Database", "FoodComparison"]),
        .feature(name: "FoodComparison", dependencies: ["QuantityPicker"]),
        .feature(name: "MealList", dependencies: ["Database", "MealForm", "MealDetails"]),
        .feature(name: "MealDetails", dependencies: ["FoodDetails", "FoodComparison", "MealForm"]),
        .feature(name: "MealForm", dependencies: ["Database", "AddIngredients"]),
        .feature(name: "AddIngredients", dependencies: ["Database", "IngredientPicker"]),
        .feature(name: "IngredientPicker", dependencies: ["QuantityPicker"]),
        .feature(name: "QuantityPicker"),

        .client(name: "UserPreferences", dependencies: ["UserDefaults", asyncSemaphoreDependency]),
        .client(name: "UserDefaults"),
        .client(name: "API"),
        .client(name: "Database", dependencies: [grdbDependency]),
        .client(name: "Ads", dependencies: [billboardDependency]),
        .client(name: "Spotlight"),

        .target(
            name: "Shared",
            dependencies: [
                tcaDIDependency,
                tcaDIMacroDependency
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        .featureTests(for: "TabBar"),
        .featureTests(for: "FoodList"),
        .featureTests(for: "FoodDetails"),
        .featureTests(for: "FoodSelection"),
        .featureTests(for: "FoodComparison"),
        .featureTests(for: "MealList"),
        .featureTests(for: "MealDetails"),
        .featureTests(for: "MealForm"),
        .featureTests(for: "AddIngredients"),
        .featureTests(for: "IngredientPicker"),
        .featureTests(for: "QuantityPicker"),

        .testTarget(for: "API"),
        .testTarget(for: "Shared"),
    ]
)

extension Target {
    /// adds `Shared`, `DI` and `DIMacro` as default dependencies
    static func client(name: String, dependencies: [Dependency] = []) -> Target {
        .target(
            name: name,
            dependencies: ["Shared", tcaDIDependency, tcaDIMacroDependency] + dependencies,
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    }

    /// adds `TCA` as a default dependency
    static func feature(name: String, dependencies: [Dependency] = []) -> Target {
        .target(
            name: name,
            dependencies: ["Shared", tcaDependency] + dependencies,
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
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
            dependencies: CollectionOfOne(.target(name: target)) + dependencies,
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    }
}

extension Product {
    static func library(name: String, type: PackageDescription.Product.Library.LibraryType? = nil) -> PackageDescription.Product {
        .library(name: name, type: type, targets: [name])
    }
}
