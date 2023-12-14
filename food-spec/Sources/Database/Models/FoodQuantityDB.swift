import Foundation
import GRDB
import Shared

struct FoodQuantityDB: Hashable, Codable {
    var recipeId: Int64
    var foodId: Int64
    var quantity: Double
    var unit: Int
}

extension FoodQuantityDB: FetchableRecord, MutablePersistableRecord {
    static let food = belongsTo(FoodDB.self).forKey("food")
    static let recipe = belongsTo(RecipeDB.self).forKey("recipe")

    var food: QueryInterfaceRequest<FoodDB> {
        request(for: Self.food)
    }

    var recipe: QueryInterfaceRequest<RecipeDB> {
        request(for: Self.recipe)
    }
}
