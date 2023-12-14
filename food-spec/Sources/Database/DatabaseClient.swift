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
            try Food
                .order(order == .forward ? column : column.desc)
                .fetchAll(db)
        }
        @Sendable func fetchRecipes(db: Database) throws -> [Recipe] {
            let request = RecipeDB
                .including(all: RecipeDB.foodQuantities.including(required: FoodQuantityDB.food))
                .order(Column("name"))
            let rows = try Row.fetchAll(db, request)
            return try rows.map(Recipe.init)
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
                    try Food
                        .filter(Column("name") == name)
                        .fetchOne($0)
                }
            },
            insertFood: { food in
                try await db.write {
                    var food = food
                    try food.upsert($0)
                    return food
                }
            },
            deleteFood: { food in
                try await db.write {
                    _ = try food.delete($0)
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
                        var recipeDb = RecipeDB(id: recipe.id, name: recipe.name, instructions: recipe.instructions)
                        try recipeDb.upsert($0)
                        guard let recipeId = recipeDb.id else {
                            struct MissingID: Error { }
                            throw MissingID()
                        }

                        var foodQuantities: [FoodQuantity] = []
                        for var foodQuantity in recipe.foodQuantities where foodQuantity.food.id != nil {
                            var fq = FoodQuantityDB(
                                id: foodQuantity.id,
                                recipeId: recipeId,
                                foodId: foodQuantity.food.id!,
                                quantity: foodQuantity.quantity.value,
                                unit: foodQuantity.quantity.unit.intValue
                            )
                            try fq.upsert($0)
                            foodQuantity.id = fq.id
                            foodQuantities.append(foodQuantity)
                        }

                        return Recipe(id: recipeId, name: recipeDb.name, foodQuantities: foodQuantities, instructions: recipeDb.instructions)
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
