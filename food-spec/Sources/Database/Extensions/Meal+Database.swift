import Foundation
import GRDB
import Shared

extension Meal: FetchableRecord {
    public init(row: Row) {
        self.init(
            id: row["id"],
            name: row["name"],
            ingredients: row.prefetchedRows["ingredients"]?.map(Ingredient.init) ?? [],
            servings: row["servings"],
            instructions: row["instructions"]
        )
    }

    init(mealDb: MealDB, ingredients: [(IngredientDB, FoodDB)]) {
        self.init(
            id: mealDb.id,
            name: mealDb.name,
            ingredients: ingredients.map(Ingredient.init),
            servings: mealDb.servings,
            instructions: mealDb.instructions
        )
    }
}

extension MealDB {
    init(meal: Meal) {
        self.init(
            id: meal.id,
            name: meal.name,
            servings: meal.servings,
            instructions: meal.instructions
        )
    }
}
