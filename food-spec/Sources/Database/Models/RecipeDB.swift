import Foundation
import GRDB
import Shared

struct RecipeDB: Hashable, Codable {
    var id: Int64?
    var name: String
    var instructions: String
}

extension RecipeDB: FetchableRecord, MutablePersistableRecord {
    static let foodQuantities = hasMany(FoodQuantityDB.self).forKey("foodQuantities")
    static let foods = hasMany(Food.self, through: foodQuantities, using: FoodQuantityDB.food)

    var foodQuantities: QueryInterfaceRequest<FoodQuantityDB> {
        request(for: Self.foodQuantities)
    }

    var foods: QueryInterfaceRequest<Food> {
        request(for: Self.foods)
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
