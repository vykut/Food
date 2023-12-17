import Foundation

public struct Meal: Hashable, Sendable {
    public var id: Int64?
    public var name: String
    public var ingredients: [Ingredient]
    public var servings: Double
    public var instructions: String

    public var servingQuantity: Quantity {
        totalQuantity / servings
    }

    public var totalQuantity: Quantity {
        ingredients.reduce(.zero) { $0 + $1.quantity }
    }

    public init(id: Int64? = nil, name: String, ingredients: [Ingredient], servings: Double, instructions: String) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.servings = servings
        self.instructions = instructions
    }
}

public extension Meal {
    static var preview: Self {
        .init(
            name: "Preview",
            ingredients: [
                .preview
            ],
            servings: 2,
            instructions: "Some notes"
        )
    }
}
