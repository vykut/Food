//
//  Item.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import Foundation
import SwiftData

@Model 
final class Food {
    @Attribute(.unique) var name: String
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

    init(
        name: String,
        energy: Energy,
        fatTotal: Quantity,
        fatSaturated: Quantity,
        protein: Quantity,
        sodium: Quantity,
        potassium: Quantity,
        cholesterol: Quantity,
        carbohydrates: Quantity,
        fiber: Quantity,
        sugar: Quantity
    ) {
        self.name = name
        self.energy = energy
        self.fatTotal = fatTotal
        self.fatSaturated = fatSaturated
        self.protein = protein
        self.sodium = sodium
        self.potassium = potassium
        self.cholesterol = cholesterol
        self.carbohydrates = carbohydrates
        self.fiber = fiber
        self.sugar = sugar
    }
}

extension Food {
    enum SortingStrategy: Codable, Hashable, Identifiable, CaseIterable {
        case name
        case energy
        case protein
        case carbohydrates
        case fat

        var id: Self { self }

        var text: String {
            switch self {
                case .name: "name"
                case .energy: "energy"
                case .protein: "protein"
                case .carbohydrates: "carbohydrates"
                case .fat: "fat"
            }
        }
    }
}

extension Food {
    convenience init(foodApiModel: FoodApiModel) {
        self.init(
            name: foodApiModel.name,
            energy: .init(value: foodApiModel.calories, unit: .kilocalories),
            fatTotal: .init(value: foodApiModel.fatTotalG, unit: .grams),
            fatSaturated: .init(value: foodApiModel.fatSaturatedG, unit: .grams),
            protein: .init(value: foodApiModel.proteinG, unit: .grams),
            sodium: .init(value: foodApiModel.sodiumMg, unit: .milligrams),
            potassium: .init(value: foodApiModel.potassiumMg, unit: .milligrams),
            cholesterol: .init(value: foodApiModel.cholesterolMg, unit: .milligrams),
            carbohydrates:  .init(value: foodApiModel.carbohydratesTotalG, unit: .grams),
            fiber: .init(value: foodApiModel.fiberG, unit: .grams),
            sugar: .init(value: foodApiModel.sugarG, unit: .grams)
        )
    }
}

extension Food {
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
