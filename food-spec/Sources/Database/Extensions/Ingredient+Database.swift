import Foundation
import GRDB
import Shared

extension Ingredient: FetchableRecord {
    public init(row: Row) {
        var quantity = Quantity(value: row["quantity"])
        if let unit = Quantity.Unit.fromDatabaseValue(row["unit"]) {
            quantity.convert(to: unit)
        }

        self.init(
            id: row["id"],
            food: row["food"],
            quantity: quantity
        )
    }

    init(ingredient: IngredientDB, foodDb: FoodDB) {
        var quantity = Quantity(value: ingredient.quantity)
        if let unit = Quantity.Unit.fromDatabaseValue(ingredient.unit.databaseValue) {
            quantity.convert(to: unit)
        }

        self.init(
            food: .init(foodDb: foodDb),
            quantity: quantity
        )
    }
}

extension IngredientDB {
    init(ingredient: Ingredient, mealId: Int64) throws {
        guard let foodId = ingredient.food.id else {
            struct MissingID: Error { }
            throw MissingID()
        }
        self.init(
            mealId: mealId,
            foodId: foodId,
            quantity: ingredient.quantity.convertedToBaseUnit().value,
            unit: ingredient.quantity.unit.intValue
        )
    }
}
