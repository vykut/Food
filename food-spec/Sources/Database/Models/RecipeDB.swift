import Foundation
import GRDB
import Shared

struct RecipeDB: Hashable, Codable {
    var id: Int64?
    var name: String
    var instructions: String
}

extension RecipeDB: FetchableRecord, MutablePersistableRecord {
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
