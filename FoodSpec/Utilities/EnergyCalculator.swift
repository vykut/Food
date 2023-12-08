//
//  EnergyCalculator.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 08/12/2023.
//

import Foundation

struct EnergyCalculator {
    struct EnergyBreakdown: Hashable {
        let protein: Energy
        let carbohydrates: Energy
        let fat: Energy

        var total: Energy {
            protein + carbohydrates + fat
        }

        var proteinRatio: Double {
            protein.value / total.value
        }

        var carbohydratesRatio: Double {
            carbohydrates.value / total.value
        }

        var fatRatio: Double {
            fat.value / total.value
        }
    }

    func calculateEnergy(for food: Food) -> EnergyBreakdown {
        .init(
            protein: calculateEnergy(protein: food.protein),
            carbohydrates: calculateEnergy(carbohydrates: food.carbohydrates),
            fat: calculateEnergy(fat: food.fatTotal)
        )
    }

    func calculateEnergy(protein quantity: Quantity) -> Energy {
        calculateEnergy(quantity: quantity, energyPerGram: 4)
    }

    func calculateEnergy(carbohydrates quantity: Quantity) -> Energy {
        calculateEnergy(quantity: quantity, energyPerGram: 4)
    }

    func calculateEnergy(fat quantity: Quantity) -> Energy {
        calculateEnergy(quantity: quantity, energyPerGram: 9)
    }

    private func calculateEnergy(quantity: Quantity, energyPerGram: Double) -> Energy {
        var quantity = quantity
        if quantity.unit != .grams {
            quantity = quantity.converted(to: .grams)
        }
        let kcal = quantity.value * energyPerGram
        return .init(value: kcal, unit: .kilocalories)
    }
}
