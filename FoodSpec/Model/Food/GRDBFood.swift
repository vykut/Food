//
//  GRDBFood.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 05/12/2023.
//

import Foundation
import GRDB

struct GRDBFood: Codable, Hashable {
    var id: Int64?
    var name: String
    var energy: Energy
    var fatTotal: Quantity
    var fatSaturated: Quantity
    var protein: Quantity
    var sodium: Quantity
    var potassium: Quantity
    var cholesterol: Quantity
    var carbohydrates: Quantity
    var fiber: Quantity
    var sugar: Quantity
}

extension GRDBFood: FetchableRecord, MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension Energy: DatabaseValueConvertible {
    var databaseValue: DatabaseValue {
        self.measurement.converted(to: .kilocalories).value.databaseValue
    }

    static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Energy? {
        guard let value = Double.fromDatabaseValue(dbValue) else { return nil }
        return .init(value: value, unit: .kilocalories)
    }
}

extension Quantity: DatabaseValueConvertible {
    var databaseValue: DatabaseValue {
        self.measurement.converted(to: .grams).value.databaseValue
    }

    static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Quantity? {
        guard let value = Double.fromDatabaseValue(dbValue) else { return nil }
        return .init(value: value, unit: .grams)
    }
}

extension GRDBFood {
    static var preview: Self {
        .init(
            name: "eggplant",
            energy: .init(value: 34.7, unit: .kilocalories),
            fatTotal: .init(value: 0.2, unit: .grams),
            fatSaturated: .init(value: 0.0, unit: .grams),
            protein: .init(value: 0.8, unit: .grams),
            sodium: .init(value: 0.0, unit: .milligrams),
            potassium: .init(value: 15.0, unit: .milligrams),
            cholesterol: .init(value: 0.0, unit: .milligrams),
            carbohydrates: .init(value: 8.7, unit: .grams),
            fiber: .init(value: 2.5, unit: .grams),
            sugar: .init(value: 3.2, unit: .grams)
        )
    }
}
