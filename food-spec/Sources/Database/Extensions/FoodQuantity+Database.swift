import Foundation
import GRDB
import Shared

extension FoodQuantity: FetchableRecord {
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

    init(foodQuantityDb: FoodQuantityDB, foodDb: FoodDB) throws {
        guard let unit = Quantity.Unit.fromDatabaseValue(foodQuantityDb.unit.databaseValue) else {
            struct InvalidUnit: Error { }
            throw InvalidUnit()
        }

        self.init(
            food: .init(foodDb: foodDb),
            quantity: .init(
                value: foodQuantityDb.quantity,
                unit: unit
            )
        )
    }
}

extension FoodQuantityDB {
    init(foodQuantity: FoodQuantity, recipeId: Int64) throws {
        guard let foodId = foodQuantity.food.id else {
            struct MissingID: Error { }
            throw MissingID()
        }
        self.init(
            recipeId: recipeId,
            foodId: foodId,
            quantity: foodQuantity.quantity.value,
            unit: foodQuantity.quantity.unit.intValue
        )
    }
}
