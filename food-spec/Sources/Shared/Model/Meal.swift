import Foundation

public struct Meal: Hashable, Sendable {
    public var id: Int64?
    public var name: String
    public var ingredients: [Ingredient]
    public var servingSize: Quantity
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

    public var nutritionalValuesPerServingSize: Ingredient {
        var baseIngredient = Ingredient(
            food: .zero(name: name),
            quantity: servingSize
        )

        let total = ingredients.reduce(Quantity.zero) { $0 + $1.quantity }
        let servingSizePercentageOfTotal = servingSize.convertedToBaseUnit().value / total.value

        for ingredient in ingredients {
            let ingredientPercentageOfTotal = ingredient.quantity.convertedToBaseUnit().value / total.value
            let ingredientQuantityInServingSize = servingSizePercentageOfTotal * ingredientPercentageOfTotal * total.value
            let ingredientQuantity = Quantity(value: ingredientQuantityInServingSize)
            let ingredientInServingSize = ingredient.food.changingServingSize(to: ingredientQuantity)

            baseIngredient.food.energy += ingredientInServingSize.energy
            baseIngredient.food.fatTotal += ingredientInServingSize.fatTotal
            baseIngredient.food.fatSaturated += ingredientInServingSize.fatSaturated
            baseIngredient.food.protein += ingredientInServingSize.protein
            baseIngredient.food.sodium += ingredientInServingSize.sodium
            baseIngredient.food.potassium += ingredientInServingSize.potassium
            baseIngredient.food.cholesterol += ingredientInServingSize.cholesterol
            baseIngredient.food.carbohydrate += ingredientInServingSize.carbohydrate
            baseIngredient.food.fiber += ingredientInServingSize.fiber
            baseIngredient.food.sugar += ingredientInServingSize.sugar
        }

        return baseIngredient
    }

    public init(id: Int64? = nil, name: String, ingredients: [Ingredient], servingSize: Quantity, instructions: String) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.servingSize = servingSize
        self.instructions = instructions
    }
}

fileprivate extension Food {
    static func zero(name: String) -> Self {
        .init(
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
        )
    }
}
