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

    // MARK: Meals
    public var observeMeals: () -> AsyncStream<[Meal]> = { .finished }
    public var getMeals: () async throws -> [Meal]
    @DependencyEndpoint(method: "insert")
    public var insertMeal: (_ meal: Meal) async throws -> Meal
    @DependencyEndpoint(method: "delete")
    public var deleteMeal: (_ meal: Meal) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    public static var liveValue: DatabaseClient = {
        let db = createAppDatabase()
        @Sendable func fetchFoods(db: Database, sortedBy column: Column, order: SortOrder) throws -> [Food] {
            let request = FoodDB.order(order == .forward ? column : column.desc)
            return try Food.fetchAll(db, request)
        }
        @Sendable func fetchMeals(db: Database) throws -> [Meal] {
            let request = MealDB
                .including(all: MealDB.ingredients.including(required: IngredientDB.food))
                .order(Column("name"))
            return try Meal.fetchAll(db, request)
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
            observeMeals: {
                let observation = ValueObservation.tracking {
                    try fetchMeals(db: $0)
                }
                return AsyncStream(observation.values(in: db))
            },
            getMeals: {
                try await db.read {
                    try fetchMeals(db: $0)
                }
            },
            insertMeal: { meal in
                try await db.write {
                    do {
                        var mealDb = MealDB(meal: meal)
                        try mealDb.upsert($0)
                        guard let mealId = mealDb.id else {
                            struct MissingID: Error { }
                            throw MissingID()
                        }

                        var ingredients: [(IngredientDB, FoodDB)] = []
                        for var ingredient in meal.ingredients {
                            var foodDB = FoodDB(food: ingredient.food)
                            try foodDB.upsert($0)
                            ingredient.food = Food(foodDb: foodDB)

                            var foodQuantityDB = try IngredientDB(ingredient: ingredient, mealId: mealId)
                            try foodQuantityDB.upsert($0)
                            ingredients.append((foodQuantityDB, foodDB))
                        }

                        return Meal(mealDb: mealDb, ingredients: ingredients)
                    } catch {
                        try $0.rollback()
                        throw error
                    }
                }
            },
            deleteMeal: { meal in
                try await db.write {
                    _ = try MealDB.deleteOne($0, key: meal.id)
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
