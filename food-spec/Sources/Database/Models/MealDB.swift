import Foundation
import GRDB
import Shared

struct MealDB: Hashable, Codable {
    var id: Int64?
    var name: String
    var servings: Double
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

extension MealDB {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let servings = Column(CodingKeys.servings)
        static let instructions = Column(CodingKeys.instructions)
    }
}
