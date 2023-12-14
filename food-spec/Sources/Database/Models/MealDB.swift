import Foundation
import GRDB
import Shared

struct MealDB: Hashable, Codable {
    var id: Int64?
    var name: String
    /// servingSize is stored in grams
    var servingSize: Double
    var servingSizeUnit: Int
    var instructions: String
}

extension MealDB: FetchableRecord, MutablePersistableRecord {
    static let ingredients = hasMany(IngredientDB.self).forKey("ingredients")
    static let foods = hasMany(FoodDB.self, through: ingredients, using: IngredientDB.food).forKey("foods") // not checked if works

    var ingredients: QueryInterfaceRequest<IngredientDB> {
        request(for: Self.ingredients)
    }

    var foods: QueryInterfaceRequest<FoodDB> {
        request(for: Self.foods)
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
