import Foundation
import GRDB
import Shared

struct FoodQuantityDB: Hashable, Codable {
    var id: Int64?
    var recipeId: Int64
    var foodId: Int64
    var quantity: Double
    var unit: Int
}

extension FoodQuantityDB: FetchableRecord, MutablePersistableRecord {
    static let food = belongsTo(Food.self)
    static let recipe = belongsTo(RecipeDB.self)

    var food: QueryInterfaceRequest<Food> {
        request(for: Self.food)
    }

    var recipe: QueryInterfaceRequest<RecipeDB> {
        request(for: Self.recipe)
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
