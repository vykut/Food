import Foundation
import GRDB
import Shared

extension Recipe: FetchableRecord {
    public init(row: Row) throws {
        self.init(
            id: row["id"],
            name: row["name"],
            foodQuantities: row["foodQuantities"],
            instructions: row["instructions"]
        )
    }
}
