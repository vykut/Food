//
//  EnergyCalculator.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 08/12/2023.
//

import Foundation
import Shared

struct EnergyCalculator {
    struct EnergyBreakdown: Hashable {
        let protein: Energy
        let carbohydrate: Energy
        let fat: Energy

        var total: Energy {
            protein + carbohydrate + fat
        }

        var proteinRatio: Double {
            protein.value / total.value
        }

        var carbohydrateRatio: Double {
            carbohydrate.value / total.value
        }

        var fatRatio: Double {
            fat.value / total.value
        }
    }

    func calculateEnergy(for food: Food) -> EnergyBreakdown {
        .init(
            protein: calculateEnergy(protein: food.protein),
            carbohydrate: calculateEnergy(carbohydrate: food.carbohydrate),
            fat: calculateEnergy(fat: food.fatTotal)
        )
    }

    func calculateEnergy(protein quantity: Quantity) -> Energy {
        calculateEnergy(quantity: quantity, energyPerGram: 4)
    }

    func calculateEnergy(carbohydrate quantity: Quantity) -> Energy {
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
