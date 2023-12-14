import Foundation
import GRDB
import Shared

extension Ingredient: FetchableRecord {
    public init(row: Row) throws {
        guard let unit = Quantity.Unit.fromDatabaseValue(row["unit"]) else {
            struct InvalidUnit: Error { }
            throw InvalidUnit()
        }

        self.init(
            id: row["id"],
            food: row["food"],
            quantity: .init(
                value: row["quantity"],
                unit: unit
            )
        )
    }

    init(ingredient: IngredientDB, foodDb: FoodDB) throws {
        guard let unit = Quantity.Unit.fromDatabaseValue(ingredient.unit.databaseValue) else {
            struct InvalidUnit: Error { }
            throw InvalidUnit()
        }

        self.init(
            food: .init(foodDb: foodDb),
            quantity: .init(
                value: ingredient.quantity,
                unit: unit
            )
        )
    }
}

extension IngredientDB {
    init(ingredient: Ingredient, recipeId: Int64) throws {
        guard let foodId = ingredient.food.id else {
            struct MissingID: Error { }
            throw MissingID()
        }
        self.init(
            recipeId: recipeId,
            foodId: foodId,
            quantity: ingredient.quantity.value,
            unit: ingredient.quantity.unit.intValue
        )
    }
}
