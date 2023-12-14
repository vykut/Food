import Foundation
import GRDB

struct FoodDB: Hashable, Codable {
    var id: Int64?
    var name: String
    var energy: Double
    var fatTotal: Double
    var fatSaturated: Double
    var protein: Double
    var sodium: Double
    var potassium: Double
    var cholesterol: Double
    var carbohydrate: Double
    var fiber: Double
    var sugar: Double
}

extension FoodDB: FetchableRecord, MutablePersistableRecord {
    static let ingredients = hasMany(IngredientDB.self).forKey("ingredients")
    static let meals = hasMany(MealDB.self, through: ingredients, using: IngredientDB.meal).forKey("meals") // has not been tested

    var ingredients: QueryInterfaceRequest<IngredientDB> {
        request(for: Self.ingredients)
    }

    var meals: QueryInterfaceRequest<MealDB> {
        request(for: Self.meals)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
