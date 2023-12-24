import Foundation
import Shared
import Dependencies
import DependenciesMacros
@_exported import GRDB

@DependencyClient
public struct DatabaseClient: Sendable {
    // MARK: Foods
    public var observeFoods: (_ sortedBy: Food.SortStrategy, _ order: SortOrder) -> AsyncStream<[Food]> = { _, _ in .finished }
    public var getAllFoods: (_ sortedBy: Food.SortStrategy, _ order: SortOrder) async throws -> [Food]
    public var numberOfFoods: (_ matching: String) async throws -> Int
    public var getFoods: (_ matching: String, _ sortedBy: Food.SortStrategy, _ order: SortOrder) async throws -> [Food]
    @DependencyEndpoint(method: "getFood")
    public var getFoodId: (_ id: Int64) async throws -> Food?
    @DependencyEndpoint(method: "getFood")
    public var getFoodName: (_ name: String) async throws -> Food?
    @DependencyEndpoint(method: "insert")
    public var insertFood: (_ food: Food) async throws -> Food
    @DependencyEndpoint(method: "insert")
    public var insertFoods: (_ foods: [Food]) async throws -> [Food]
    @DependencyEndpoint(method: "delete")
    public var deleteFoods: (_ foods: [Food]) async throws -> Void

    // MARK: Meals
    public var observeMeals: (_ sortedBy: Meal.SortStrategy, _ order: SortOrder) -> AsyncStream<[Meal]> = { _, _ in .finished }
    public var getAllMeals: (_ sortedBy: Meal.SortStrategy, _ order: SortOrder) async throws -> [Meal]
    public var getMeals: (_ matching: String, _ sortedBy: Meal.SortStrategy, _ order: SortOrder) async throws -> [Meal]
    @DependencyEndpoint(method: "getMeal")
    public var getMealId: (_ id: Int64) async throws -> Meal?
    @DependencyEndpoint(method: "insert")
    public var insertMeal: (_ meal: Meal) async throws -> Meal
    @DependencyEndpoint(method: "delete")
    public var deleteMeals: (_ meals: [Meal]) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    public static var liveValue: DatabaseClient = {
        let db = createAppDatabase()

        @Sendable func fetchFoods(db: Database, sortedBy column: Column, order: SortOrder) throws -> [Food] {
            let request = FoodDB.order(order == .forward ? column : column.desc)
            return try Food.fetchAll(db, request)
        }
        
        @Sendable func fetchMeals(db: Database, matching query: String? = nil, sortedBy column: Column, order: SortOrder) throws -> [Meal] {
            var request = MealDB
                .including(
                    all: MealDB.ingredients
                        .including(
                            required: IngredientDB.food
                                .order(MealDB.Columns.name)
                        )
                )
            if let query {
                request = request.filter(MealDB.Columns.name.like("%\(query)%"))
            }
            request = request.order(order == .forward ? column : column.desc)
            return try Meal.fetchAll(db, request)
        }

        return .init(
            observeFoods: { strategy, order in
                let observation = ValueObservation.tracking {
                    try fetchFoods(db: $0, sortedBy: strategy.column, order: order)
                }
                return AsyncStream(observation.removeDuplicates().values(in: db))
            },
            getAllFoods: { strategy, order in
                return try await db.read {
                    try fetchFoods(db: $0, sortedBy: strategy.column, order: order)
                }
            },
            numberOfFoods: { matching in
                try await db.read {
                    try FoodDB
                        .filter(FoodDB.Columns.name.like("%\(matching)%"))
                        .fetchCount($0)
                }
            },
            getFoods: { matching, strategy, order in
                try await db.read {
                    let column = strategy.column
                    let request = FoodDB
                        .filter(FoodDB.Columns.name.like("%\(matching)%"))
                        .order(order == .forward ? column : column.desc)
                    return try Food.fetchAll($0, request)
                }
            },
            getFoodId: { id in
                return try await db.read {
                    let foodDb = try FoodDB.fetchOne($0, key: id)
                    return foodDb.map(Food.init)
                }
            },
            getFoodName: { name in
                return try await db.read {
                    let request = FoodDB.filter(FoodDB.Columns.name == name)
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
            insertFoods: { foods in
                try await db.write {
                    do {
                        var insertedFoods: [Food] = []
                        for food in foods {
                            var foodDb = FoodDB(food: food)
                            try foodDb.upsert($0)
                            insertedFoods.append(Food(foodDb: foodDb))
                        }
                        return insertedFoods
                    } catch {
                        try $0.rollback()
                        throw error
                    }
                }
            },
            deleteFoods: { foods in
                try await db.write {
                    _ = try FoodDB.deleteAll($0, keys: foods.map(\.id))
                }
            },
            observeMeals: { strategy, order in
                let observation = ValueObservation.tracking {
                    try fetchMeals(db: $0, sortedBy: strategy.column, order: order)
                }
                return AsyncStream(observation.removeDuplicates().values(in: db))
            },
            getAllMeals: { strategy, order in
                try await db.read {
                    try fetchMeals(db: $0, sortedBy: strategy.column, order: order)
                }
            },
            getMeals: { query, strategy, order in
                try await db.read {
                    try fetchMeals(db: $0, matching: query, sortedBy: strategy.column, order: order)
                }
            },
            getMealId: { id in
                try await db.read {
                    let request = MealDB
                        .filter(key: id)
                        .including(
                            all: MealDB.ingredients
                                .including(
                                    required: IngredientDB.food
                                        .order(MealDB.Columns.name)
                                )
                        )
                    return try Meal.fetchOne($0, request)
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
            deleteMeals: { meals in
                try await db.write {
                    _ = try MealDB.deleteAll($0, keys: meals.map(\.id))
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
