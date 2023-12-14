import Foundation
import GRDB
import Shared

extension Meal: FetchableRecord {
    public init(row: Row) {
        var quantity = Quantity(value: row["servingSize"])
        if let unit = Quantity.Unit.fromDatabaseValue(row["servingSizeUnit"]) {
            quantity.convert(to: unit)
        }

        self.init(
            id: row["id"],
            name: row["name"],
            ingredients: row.prefetchedRows["ingredients"]?.map(Ingredient.init) ?? [],
            servingSize: quantity,
            instructions: row["instructions"]
        )
    }

    init(mealDb: MealDB, ingredients: [(IngredientDB, FoodDB)]) {
        var quantity = Quantity(value: mealDb.servingSize)
        if let unit = Quantity.Unit.fromDatabaseValue(mealDb.servingSizeUnit.databaseValue) {
            quantity.convert(to: unit)
        }

        self.init(
            id: mealDb.id,
            name: mealDb.name,
            ingredients: ingredients.map(Ingredient.init),
            servingSize: quantity,
            instructions: mealDb.instructions
        )
    }
}

extension MealDB {
    init(meal: Meal) {
        self.init(
            id: meal.id,
            name: meal.name,
            servingSize: meal.servingSize.convertedToBaseUnit().value,
            servingSizeUnit: meal.servingSize.unit.intValue,
            instructions: meal.instructions
        )
    }
}
