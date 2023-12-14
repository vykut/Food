import Foundation
import GRDB
import Shared

struct IngredientDB: Hashable, Codable {
    var mealId: Int64
    var foodId: Int64
    var quantity: Double
    var unit: Int
}

extension IngredientDB: FetchableRecord, MutablePersistableRecord {
    static let food = belongsTo(FoodDB.self).forKey("food")
    static let meal = belongsTo(MealDB.self).forKey("meal")

    var food: QueryInterfaceRequest<FoodDB> {
        request(for: Self.food)
    }

    var meal: QueryInterfaceRequest<MealDB> {
        request(for: Self.meal)
    }
}
