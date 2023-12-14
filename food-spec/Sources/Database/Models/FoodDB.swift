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
    static let quantities = hasMany(FoodQuantityDB.self).forKey("quantities")
    static let recipes = hasMany(RecipeDB.self, through: quantities, using: FoodQuantityDB.recipe).forKey("recipes") // has not been tested

    var quantities: QueryInterfaceRequest<FoodQuantityDB> {
        request(for: Self.quantities)
    }

    var recipes: QueryInterfaceRequest<RecipeDB> {
        request(for: Self.recipes)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
