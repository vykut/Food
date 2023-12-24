import Foundation

public struct EnergyCalculator: Sendable {
    public struct EnergyBreakdown: Hashable, Sendable {
        public let protein: Energy
        public let carbohydrate: Energy
        public let fat: Energy

        public var total: Energy {
            protein + carbohydrate + fat
        }

        public var proteinRatio: Double {
            protein.value / total.value
        }

        public var carbohydrateRatio: Double {
            carbohydrate.value / total.value
        }

        public var fatRatio: Double {
            fat.value / total.value
        }
    }

    public init() { }

    public func calculateEnergy(for food: Food) -> EnergyBreakdown {
        .init(
            protein: calculateEnergy(protein: food.protein),
            carbohydrate: calculateEnergy(carbohydrate: food.carbohydrate),
            fat: calculateEnergy(fat: food.fatTotal)
        )
    }

    public func calculateEnergy(protein quantity: Quantity) -> Energy {
        calculateEnergy(quantity: quantity, energyPerGram: 4)
    }

    func calculateEnergy(carbohydrate quantity: Quantity) -> Energy {
        calculateEnergy(quantity: quantity, energyPerGram: 4)
    }

    public func calculateEnergy(fat quantity: Quantity) -> Energy {
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
