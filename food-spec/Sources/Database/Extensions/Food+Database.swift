import Foundation
import Shared
import GRDB

extension Food: FetchableRecord {
    public init(row: Row) throws {
        self.init(
            id: row["id"],
            name: row["name"],
            energy: .init(value: row["energy"], unit: Energy.baseUnit),
            fatTotal: .init(value: row["fatTotal"], unit: Quantity.baseUnit),
            fatSaturated: .init(value: row["fatSaturated"], unit: Quantity.baseUnit),
            protein: .init(value: row["protein"], unit: Quantity.baseUnit),
            sodium: .init(value: row["sodium"], unit: Quantity.baseUnit),
            potassium: .init(value: row["potassium"], unit: Quantity.baseUnit),
            cholesterol: .init(value: row["cholesterol"], unit: Quantity.baseUnit),
            carbohydrate: .init(value: row["carbohydrate"], unit: Quantity.baseUnit),
            fiber: .init(value: row["fiber"], unit: Quantity.baseUnit),
            sugar: .init(value: row["sugar"], unit: Quantity.baseUnit)
        )
    }

    init(foodDb: FoodDB) {
        self.init(
            id: foodDb.id,
            name: foodDb.name,
            energy: .init(value: foodDb.energy),
            fatTotal: .init(value: foodDb.fatTotal),
            fatSaturated: .init(value: foodDb.fatSaturated),
            protein: .init(value: foodDb.protein),
            sodium: .init(value: foodDb.sodium),
            potassium: .init(value: foodDb.potassium),
            cholesterol: .init(value: foodDb.cholesterol),
            carbohydrate: .init(value: foodDb.carbohydrate),
            fiber: .init(value: foodDb.fiber),
            sugar: .init(value: foodDb.sugar)
        )
    }
}

extension FoodDB {
    init(food: Food) {
        self.init(
            id: food.id,
            name: food.name,
            energy: food.energy.convertedToBaseUnit().value,
            fatTotal: food.fatTotal.convertedToBaseUnit().value,
            fatSaturated: food.fatSaturated.convertedToBaseUnit().value,
            protein: food.protein.convertedToBaseUnit().value,
            sodium: food.sodium.convertedToBaseUnit().value,
            potassium: food.potassium.convertedToBaseUnit().value,
            cholesterol: food.cholesterol.convertedToBaseUnit().value,
            carbohydrate: food.carbohydrate.convertedToBaseUnit().value,
            fiber: food.fiber.convertedToBaseUnit().value,
            sugar: food.sugar.convertedToBaseUnit().value
        )
    }
}

public extension Food.SortStrategy {
    var column: Column {
        switch self {
            case .name: FoodDB.Columns.name
            case .energy: FoodDB.Columns.energy
            case .carbohydrate: FoodDB.Columns.carbohydrate
            case .protein: FoodDB.Columns.protein
            case .fat: FoodDB.Columns.fatTotal
        }
    }
}
