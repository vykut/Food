import Foundation
import Shared
import GRDB

extension Food: FetchableRecord, MutablePersistableRecord {
    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension Food.SortingStrategy {
    var column: Column {
        switch self {
            case .name: Column("name")
            case .energy: Column("energy")
            case .carbohydrates: Column("carbohydrate")
            case .protein: Column("protein")
            case .fat: Column("fatTotal")
        }
    }
}

extension Energy: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
        converted(to: .kilocalories).value.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Energy? {
        guard let value = Double.fromDatabaseValue(dbValue) else { return nil }
        return .init(value: value, unit: .kilocalories)
    }
}

extension Quantity: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
        converted(to: .grams).value.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Quantity? {
        guard let value = Double.fromDatabaseValue(dbValue) else { return nil }
        return .init(value: value, unit: .grams)
    }
}
