import Foundation
import Shared
import GRDB

extension FoodQuantity: FetchableRecord, MutablePersistableRecord {
    static let food = hasOne(Food.self)

    public var food: QueryInterfaceRequest<Food> {
        request(for: Self.food)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
