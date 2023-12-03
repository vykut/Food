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
    var openDate: Date?
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
        sugar: Quantity,
        carbohydrates: Quantity,
        cholesterol: Quantity,
        fatSaturated: Quantity,
        fatTotal: Quantity,
        fiber: Quantity,
        name: String,
        potassium: Quantity,
        protein: Quantity,
        sodium: Quantity
    ) {
        self.name = name
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
    convenience init(foodApiModel: FoodApiModel, date: Date?) {
        self.init(
            sugar: .init(value: foodApiModel.sugarG, unit: .grams),
            carbohydrates:  .init(value: foodApiModel.carbohydratesTotalG, unit: .grams),
            cholesterol: .init(value: foodApiModel.cholesterolMg, unit: .milligrams),
            fatSaturated: .init(value: foodApiModel.fatSaturatedG, unit: .grams),
            fatTotal: .init(value: foodApiModel.fatTotalG, unit: .grams),
            fiber: .init(value: foodApiModel.fiberG, unit: .grams),
            name: foodApiModel.name,
            potassium: .init(value: foodApiModel.potassiumMg, unit: .milligrams),
            protein: .init(value: foodApiModel.proteinG, unit: .grams),
            sodium: .init(value: foodApiModel.sodiumMg, unit: .milligrams)
        )
    }
}

extension Food {
    static var preview: Self {
        .init(
            sugar: .init(value: 3.2, unit: .grams),
            carbohydrates: .init(value: 8.7, unit: .grams),
            cholesterol: .init(value: 0.0, unit: .milligrams),
            fatSaturated: .init(value: 0.0, unit: .grams),
            fatTotal: .init(value: 0.2, unit: .grams),
            fiber: .init(value: 2.5, unit: .grams),
            name: "eggplant",
            potassium: .init(value: 15.0, unit: .milligrams),
            protein: .init(value: 0.8, unit: .grams),
            sodium: .init(value: 0.0, unit: .milligrams)
        )
    }
}
