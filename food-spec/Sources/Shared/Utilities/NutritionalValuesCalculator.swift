import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct NutritionalValuesCalculator {
    public var nutritionalValues: (_ meal: Meal) -> Ingredient = { _ in .preview }
    public var nutritionalValuesPerServing: (_ meal: Meal) -> Ingredient = { _ in .preview }
}

extension NutritionalValuesCalculator: DependencyKey {
    public static let liveValue: NutritionalValuesCalculator = {
        func nutritionalValues(meal: Meal) -> Ingredient {
            var baseIngredient = Ingredient(
                food: .init(
                    name: meal.name,
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

            for ingredient in meal.ingredients {
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

            baseIngredient.food.energy /= baseIngredient.quantity.value
            baseIngredient.food.energy *= 100
            baseIngredient.food.fatTotal /= baseIngredient.quantity.value
            baseIngredient.food.fatTotal *= 100
            baseIngredient.food.fatSaturated /= baseIngredient.quantity.value
            baseIngredient.food.fatSaturated *= 100
            baseIngredient.food.protein /= baseIngredient.quantity.value
            baseIngredient.food.protein *= 100
            baseIngredient.food.sodium /= baseIngredient.quantity.value
            baseIngredient.food.sodium *= 100
            baseIngredient.food.potassium /= baseIngredient.quantity.value
            baseIngredient.food.potassium *= 100
            baseIngredient.food.cholesterol /= baseIngredient.quantity.value
            baseIngredient.food.cholesterol *= 100
            baseIngredient.food.carbohydrate /= baseIngredient.quantity.value
            baseIngredient.food.carbohydrate *= 100
            baseIngredient.food.fiber /= baseIngredient.quantity.value
            baseIngredient.food.fiber *= 100
            baseIngredient.food.sugar /= baseIngredient.quantity.value
            baseIngredient.food.sugar *= 100

            return baseIngredient
        }
        return .init(
            nutritionalValues: nutritionalValues,
            nutritionalValuesPerServing: { meal in
                guard meal.servings != 1 else { return nutritionalValues(meal: meal) }

                let servingQuantity = meal.servingQuantity
                var baseIngredient = Ingredient(
                    food: .zero(name: meal.name),
                    quantity: servingQuantity
                )

                let total = meal.ingredients.reduce(Quantity.zero) { $0 + $1.quantity }
                let servingSizePercentageOfTotal = servingQuantity.convertedToBaseUnit().value / total.value

                for ingredient in meal.ingredients {
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

                baseIngredient.food.energy /= servingQuantity.value
                baseIngredient.food.energy *= 100
                baseIngredient.food.fatTotal /= servingQuantity.value
                baseIngredient.food.fatTotal *= 100
                baseIngredient.food.fatSaturated /= servingQuantity.value
                baseIngredient.food.fatSaturated *= 100
                baseIngredient.food.protein /= servingQuantity.value
                baseIngredient.food.protein *= 100
                baseIngredient.food.sodium /= servingQuantity.value
                baseIngredient.food.sodium *= 100
                baseIngredient.food.potassium /= servingQuantity.value
                baseIngredient.food.potassium *= 100
                baseIngredient.food.cholesterol /= servingQuantity.value
                baseIngredient.food.cholesterol *= 100
                baseIngredient.food.carbohydrate /= servingQuantity.value
                baseIngredient.food.carbohydrate *= 100
                baseIngredient.food.fiber /= servingQuantity.value
                baseIngredient.food.fiber *= 100
                baseIngredient.food.sugar /= servingQuantity.value
                baseIngredient.food.sugar *= 100

                return baseIngredient
            }
        )
    }()

    public static let testValue: NutritionalValuesCalculator = .init()
}

public extension DependencyValues {
    var nutritionalValuesCalculator: NutritionalValuesCalculator {
        get { self[NutritionalValuesCalculator.self] }
        set { self[NutritionalValuesCalculator.self] = newValue }
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
