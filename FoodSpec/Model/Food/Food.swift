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

extension Food: FetchableRecord {
    init(row: Row) throws {
        struct DecodingError: Error { }
        guard
            let id = row["id"].flatMap({ Int64.fromDatabaseValue($0.databaseValue) }),
            let name = row["name"].flatMap({ String.fromDatabaseValue($0.databaseValue) }),
            let energy = row["energy"].flatMap({ Energy.fromDatabaseValue($0.databaseValue) }),
            let fatTotal = row["fatTotal"].flatMap({ Quantity.fromDatabaseValue($0.databaseValue) }),
            let fatSaturated = row["fatSaturated"].flatMap({ Quantity.fromDatabaseValue($0.databaseValue) }),
            let protein = row["protein"].flatMap({ Quantity.fromDatabaseValue($0.databaseValue) }),
            let sodium = row["sodium"].flatMap({ Quantity.fromDatabaseValue($0.databaseValue) }),
            let potassium = row["potassium"].flatMap({ Quantity.fromDatabaseValue($0.databaseValue) }),
            let cholesterol = row["cholesterol"].flatMap({ Quantity.fromDatabaseValue($0.databaseValue) }),
            let carbohydrate = row["carbohydrate"].flatMap({ Quantity.fromDatabaseValue($0.databaseValue) }),
            let fiber = row["fiber"].flatMap({ Quantity.fromDatabaseValue($0.databaseValue) }),
            let sugar = row["sugar"].flatMap({ Quantity.fromDatabaseValue($0.databaseValue) })
        else { throw DecodingError() }
        self.init(
            id: id,
            name: name,
            energy: energy,
            fatTotal: fatTotal,
            fatSaturated: fatSaturated,
            protein: protein,
            sodium: sodium.converted(to: .milligrams),
            potassium: potassium.converted(to: .milligrams),
            cholesterol: cholesterol.converted(to: .milligrams),
            carbohydrate: carbohydrate,
            fiber: fiber,
            sugar: sugar
        )
    }
}

extension Food: MutablePersistableRecord {
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
