import Foundation
import Shared
import GRDB

extension Recipe: FetchableRecord, MutablePersistableRecord {
    static let foodQuantities = hasMany(FoodQuantity.self)

    public var foodQuantities: QueryInterfaceRequest<FoodQuantity> {
        request(for: Self.foodQuantities)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
