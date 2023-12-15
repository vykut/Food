import Foundation

public struct Ingredient: Hashable, Sendable {
    public var id: Int64?
    public var food: Food
    public var quantity: Quantity

    public var foodWithQuantity: Food {
        food.changingServingSize(to: quantity)
    }

    public init(id: Int64? = nil, food: Food, quantity: Quantity) {
        self.id = id
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
