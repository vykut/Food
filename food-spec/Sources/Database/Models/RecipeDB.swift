import Foundation
import GRDB
import Shared

struct RecipeDB: Hashable, Codable {
    var id: Int64?
    var name: String
    var instructions: String
}

extension RecipeDB: FetchableRecord, MutablePersistableRecord {
    static let quantities = hasMany(FoodQuantityDB.self).forKey("quantities")
    static let foods = hasMany(FoodDB.self, through: quantities, using: FoodQuantityDB.food).forKey("foods") // not checked if works

    var quantities: QueryInterfaceRequest<FoodQuantityDB> {
        request(for: Self.quantities)
    }

    var foods: QueryInterfaceRequest<FoodDB> {
        request(for: Self.foods)
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
