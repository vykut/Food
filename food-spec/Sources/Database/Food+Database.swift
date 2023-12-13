import Foundation
import Shared
import GRDB

extension Food: FetchableRecord, MutablePersistableRecord {
    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension Food {
    public enum Columns {
        public static let id = Column(Food.CodingKeys.id)
        public static let name = Column(Food.CodingKeys.name)
        public static let energy = Column(Food.CodingKeys.energy)
        public static let fatTotal = Column(Food.CodingKeys.fatTotal)
        public static let protein = Column(Food.CodingKeys.protein)
        public static let sodium = Column(Food.CodingKeys.sodium)
        public static let potassium = Column(Food.CodingKeys.potassium)
        public static let cholesterol = Column(Food.CodingKeys.cholesterol)
        public static let carbohydrate = Column(Food.CodingKeys.carbohydrate)
        public static let fiber = Column(Food.CodingKeys.fiber)
        public static let sugar = Column(Food.CodingKeys.sugar)
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
