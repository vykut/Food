import Foundation

public struct Ingredient: Hashable, Sendable {
    public var food: Food
    public var quantity: Quantity

    public var foodWithQuantity: Food {
        food.changingServingSize(to: quantity)
    }

    public init(food: Food, quantity: Quantity) {
        self.food = food
        self.quantity = quantity
    }
}

public extension Ingredient {
    static var preview: Self {
        .init(
            food: .preview,
            quantity: .grams(100)
        )
    }
}
