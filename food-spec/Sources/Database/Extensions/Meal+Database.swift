import Foundation
import GRDB
import Shared

extension Meal: FetchableRecord {
    public init(row: Row) throws {
        try self.init(
            id: row["id"],
            name: row["name"],
            ingredients: row.prefetchedRows["ingredients"]?.map(Ingredient.init) ?? [],
            instructions: row["instructions"]
        )
    }

    init(mealDb: MealDB, ingredients: [(IngredientDB, FoodDB)]) throws {
        try self.init(
            id: mealDb.id,
            name: mealDb.name,
            ingredients: ingredients.map(Ingredient.init),
            instructions: mealDb.instructions
        )
    }
}

extension MealDB {
    init(meal: Meal) {
        self.init(
            id: meal.id,
            name: meal.name,
            instructions: meal.instructions
        )
    }
}
