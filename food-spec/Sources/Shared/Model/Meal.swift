import Foundation

public struct Meal: Hashable, Sendable {
    public var id: Int64?
    public var name: String
    public var ingredients: [Ingredient]
    public var instructions: String

    public var nutritionalValues: Ingredient {
        var baseIngredient = Ingredient(
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
        for ingredient in ingredients {
            baseIngredient.quantity += ingredient.quantity
            let food = ingredient.foodWithQuantity
            baseIngredient.food.energy += food.energy
            baseIngredient.food.fatTotal += food.fatTotal
            baseIngredient.food.fatSaturated += food.fatSaturated
            baseIngredient.food.protein += food.protein
            baseIngredient.food.sodium += food.sodium
            baseIngredient.food.potassium += food.potassium
            baseIngredient.food.cholesterol += food.cholesterol
            baseIngredient.food.carbohydrate += food.carbohydrate
            baseIngredient.food.fiber += food.fiber
            baseIngredient.food.sugar += food.sugar
        }
        return baseIngredient
    }

    public init(id: Int64? = nil, name: String, ingredients: [Ingredient], instructions: String) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
    }
}
