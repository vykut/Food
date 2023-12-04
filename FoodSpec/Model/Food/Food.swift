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
    var calories: Energy
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
        openDate: Date? = nil,
        calories: Energy,
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
        self.openDate = openDate
        self.calories = calories
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
            name: foodApiModel.name,
            calories: .init(value: foodApiModel.calories, unit: .kilocalories),
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
            calories: .init(value: 34.7, unit: .kilocalories),
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
