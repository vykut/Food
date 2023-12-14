import Foundation
import Shared
import Dependencies
import DependenciesMacros
@_exported import GRDB

@DependencyClient
public struct DatabaseClient {
    // MARK: Foods
    public var observeFoods: (_ sortedBy: Column, _ order: SortOrder) -> AsyncStream<[Food]> = { _, _ in .finished }
    public var getRecentFoods: (_ sortedBy: Column, _ order: SortOrder) async throws -> [Food]
    public var getFood: (_ name: String) async throws -> Food?
    @DependencyEndpoint(method: "insert")
    public var insertFood: (_ food: Food) async throws -> Food
    @DependencyEndpoint(method: "delete")
    public var deleteFood: (_ food: Food) async throws -> Void

    // MARK: Recipes
    public var observeRecipes: () -> AsyncStream<[Recipe]> = { .finished }
    public var getRecipes: () async throws -> [Recipe]
    @DependencyEndpoint(method: "insert")
    public var insertRecipe: (_ recipe: Recipe) async throws -> Recipe
    @DependencyEndpoint(method: "delete")
    public var deleteRecipe: (_ recipe: Recipe) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    public static var liveValue: DatabaseClient = {
        let db = createAppDatabase()
        @Sendable func fetchFoods(db: Database, sortedBy column: Column, order: SortOrder) throws -> [Food] {
            let request = FoodDB.order(order == .forward ? column : column.desc)
            return try Food.fetchAll(db, request)
        }
        @Sendable func fetchRecipes(db: Database) throws -> [Recipe] {
            let request = RecipeDB
                .including(all: RecipeDB.quantities.including(required: FoodQuantityDB.food))
                .order(Column("name"))
            return try Recipe.fetchAll(db, request)
        }
        return .init(
            observeFoods: { column, order in
                let observation = ValueObservation.tracking {
                    try fetchFoods(db: $0, sortedBy: column, order: order)
                }
                return AsyncStream(observation.values(in: db))
            },
            getRecentFoods: { column, order in
                return try await db.read {
                    try fetchFoods(db: $0, sortedBy: column, order: order)
                }
            },
            getFood: { name in
                return try await db.read {
                    let request = FoodDB.filter(Column("name") == name)
                    return try Food.fetchOne($0, request)
                }
            },
            insertFood: { food in
                try await db.write {
                    var foodDb = FoodDB(food: food)
                    try foodDb.upsert($0)
                    return Food(foodDb: foodDb)
                }
            },
            deleteFood: { food in
                try await db.write {
                    _ = try FoodDB.deleteOne($0, key: food.id)
                }
            },
            observeRecipes: {
                let observation = ValueObservation.tracking {
                    try fetchRecipes(db: $0)
                }
                return AsyncStream(observation.values(in: db))
            },
            getRecipes: {
                try await db.read {
                    try fetchRecipes(db: $0)
                }
            },
            insertRecipe: { recipe in
                try await db.write {
                    do {
                        var recipeDb = RecipeDB(recipe: recipe)
                        try recipeDb.upsert($0)
                        guard let recipeId = recipeDb.id else {
                            struct MissingID: Error { }
                            throw MissingID()
                        }

                        var foodQuantities: [(FoodQuantityDB, FoodDB)] = []
                        for var foodQuantity in recipe.quantities {
                            var foodDB = FoodDB(food: foodQuantity.food)
                            try foodDB.upsert($0)
                            foodQuantity.food = Food(foodDb: foodDB)

                            var foodQuantityDB = try FoodQuantityDB(foodQuantity: foodQuantity, recipeId: recipeId)
                            try foodQuantityDB.upsert($0)
                            foodQuantities.append((foodQuantityDB, foodDB))
                        }

                        return try Recipe(recipeDb: recipeDb, quantities: foodQuantities)
                    } catch {
                        try $0.rollback()
                        throw error
                    }
                }
            },
            deleteRecipe: { recipe in
                try await db.write {
                    _ = try RecipeDB(id: recipe.id, name: recipe.name, instructions: recipe.instructions).delete($0)
                }
            }
        )
    }()

    public static let testValue: DatabaseClient = .init()
}

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
