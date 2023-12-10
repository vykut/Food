//
//  Food.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 05/12/2023.
//

import Foundation
import GRDB

struct Food: Codable, Hashable {
    var id: Int64?
    var name: String
    var energy: Energy
    var fatTotal: Quantity
    var fatSaturated: Quantity
    var protein: Quantity
    var sodium: Quantity
    var potassium: Quantity
    var cholesterol: Quantity
    var carbohydrate: Quantity
    var fiber: Quantity
    var sugar: Quantity

    var nutritionalSummary: String {
        """
\(energy.formatted(width: .narrow)) | \
P: \(protein.formatted(width: .narrow)) | \
C: \(carbohydrate.formatted(width: .narrow)) | \
F: \(fatTotal.formatted(width: .narrow))
"""
    }
}

extension Food: FetchableRecord, MutablePersistableRecord {
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

extension Food {
    enum SortingStrategy: String, Codable, Identifiable, Hashable, CaseIterable {
        case name
        case energy
        case carbohydrates
        case protein
        case fat

        var id: Self { self }

        var column: Column {
            switch self {
                case .name: Column(CodingKeys.name)
                case .energy: Column(CodingKeys.energy)
                case .carbohydrates: Column(CodingKeys.carbohydrate)
                case .protein: Column(CodingKeys.protein)
                case .fat: Column(CodingKeys.fatTotal)
            }
        }
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

extension Food {
    init(foodApiModel: FoodApiModel) {
        self.init(
            name: foodApiModel.name,
            energy: .init(value: foodApiModel.calories, unit: .kilocalories),
            fatTotal: .init(value: foodApiModel.fatTotalG, unit: .grams),
            fatSaturated: .init(value: foodApiModel.fatSaturatedG, unit: .grams),
            protein: .init(value: foodApiModel.proteinG, unit: .grams),
            sodium: .init(value: foodApiModel.sodiumMg, unit: .milligrams),
            potassium: .init(value: foodApiModel.potassiumMg, unit: .milligrams),
            cholesterol: .init(value: foodApiModel.cholesterolMg, unit: .milligrams),
            carbohydrate:  .init(value: foodApiModel.carbohydratesTotalG, unit: .grams),
            fiber: .init(value: foodApiModel.fiberG, unit: .grams),
            sugar: .init(value: foodApiModel.sugarG, unit: .grams)
        )
    }
}

extension Food {
    static var preview: Self {
        .init(
            id: 1,
            name: "eggplant",
            energy: .init(value: 34.7, unit: .kilocalories),
            fatTotal: .init(value: 0.2, unit: .grams),
            fatSaturated: .init(value: 0.0, unit: .grams),
            protein: .init(value: 0.8, unit: .grams),
            sodium: .init(value: 0.0, unit: .milligrams),
            potassium: .init(value: 15.0, unit: .milligrams),
            cholesterol: .init(value: 0.0, unit: .milligrams),
            carbohydrate: .init(value: 8.7, unit: .grams),
            fiber: .init(value: 2.5, unit: .grams),
            sugar: .init(value: 3.2, unit: .grams)
        )
    }
}
