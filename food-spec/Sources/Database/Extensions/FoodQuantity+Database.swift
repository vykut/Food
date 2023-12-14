import Foundation
import GRDB
import Shared

extension FoodQuantity: FetchableRecord {
    public init(row: Row) throws {
        guard let unit = Quantity.Unit.fromDatabaseValue(row["unit"]) else {
            struct InvalidUnit: Error { }
            throw InvalidUnit()
        }

        self.init(
            id: row["id"],
            food: row["food"],
            quantity: .init(
                value: row["quantity"],
                unit: unit
            )
        )
    }

    
}
