import Foundation

public struct Recipe: Hashable, Codable, Sendable {
    public var id: Int64?
    public var name: String
    public var foodQuantities: [FoodQuantity]
    public var instructions: String

    public var nutritionalValues: FoodQuantity {
        var baseQuantity = FoodQuantity(
            food: .init(
                name: name,
                energy: .zero,
                fatTotal: .zero,
                fatSaturated: .zero,
                protein: .zero,
                sodium: .zero,
                potassium: .zero,
                cholesterol: .zero,
                carbohydrate: .zero,
                fiber: .zero,
                sugar: .zero
            ),
            quantity: .zero
        )
        for foodQuantity in foodQuantities {
            baseQuantity.quantity += foodQuantity.quantity
            let food = foodQuantity.foodWithQuantity
            baseQuantity.food.energy += food.energy
            baseQuantity.food.fatTotal += food.fatTotal
            baseQuantity.food.fatSaturated += food.fatSaturated
            baseQuantity.food.protein += food.protein
            baseQuantity.food.sodium += food.sodium
            baseQuantity.food.potassium += food.potassium
            baseQuantity.food.cholesterol += food.cholesterol
            baseQuantity.food.carbohydrate += food.carbohydrate
            baseQuantity.food.fiber += food.fiber
            baseQuantity.food.sugar += food.sugar
        }
        return baseQuantity
    }

    public init(id: Int64? = nil, name: String, foodQuantities: [FoodQuantity], instructions: String) {
        self.id = id
        self.name = name
        self.foodQuantities = foodQuantities
        self.instructions = instructions
    }
}
