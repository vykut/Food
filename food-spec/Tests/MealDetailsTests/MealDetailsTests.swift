import Foundation
import Shared
import XCTest
import ComposableArchitecture
@testable import MealDetails

@MainActor
final class MealDetailsTests: XCTestCase {
    func testStateInitialization() async throws {
        let store = TestStore(
            initialState: MealDetails.State(meal: .chimichurri),
            reducer: {
                MealDetails()
            },
            withDependencies: {
                $0.nutritionalValuesCalculator.nutritionalValues = { meal in
                    XCTAssertNoDifference(meal, .chimichurri)
                    return .zero
                }
                $0.nutritionalValuesCalculator.nutritionalValuesPerServing = { meal in
                    XCTAssertNoDifference(meal, .chimichurri)
                    return .zero
                }
            }
        )
        store.assert {
            $0.meal = .chimichurri
            $0.nutritionalValuesPerTotal = .zero
            $0.nutritionalValuesPerServing = .zero
        }
    }

    func testEditButtonTapped() async throws {
        let store = TestStore(
            initialState: MealDetails.State(meal: .chimichurri),
            reducer: {
                MealDetails()
            },
            withDependencies: {
                $0.nutritionalValuesCalculator = .zero
            }
        )
        await store.send(.editButtonTapped) {
            $0.destination = .mealForm(.init(meal: .chimichurri))
        }
    }

    func testNutritionalInfoPerServingButtonTapped() async throws {
        let store = TestStore(
            initialState: MealDetails.State(meal: .chimichurri),
            reducer: {
                MealDetails()
            },
            withDependencies: {
                $0.nutritionalValuesCalculator = .zero
            }
        )
        await store.send(.nutritionalInfoPerServingButtonTapped) {
            $0.destination = .foodDetails(.init(
                food: .zero,
                quantity: .zero
            ))
        }
    }

    func testNutritionalInfoButtonTapped() async throws {
        let store = TestStore(
            initialState: MealDetails.State(meal: .chimichurri),
            reducer: {
                MealDetails()
            },
            withDependencies: {
                $0.nutritionalValuesCalculator = .zero
            }
        )
        await store.send(.nutritionalInfoButtonTapped) {
            $0.destination = .foodDetails(.init(
                food: .zero,
                quantity: .zero
            ))
        }
    }

    func testIngredientComparisonButtonTapped() async throws {
        let store = TestStore(
            initialState: MealDetails.State(meal: .chimichurri),
            reducer: {
                MealDetails()
            },
            withDependencies: {
                $0.nutritionalValuesCalculator = .zero
            }
        )
        await store.send(.ingredientComparisonButtonTapped) {
            $0.destination = .foodComparison(.init(
                foods: [
                    .chiliPepper.changingServingSize(to: .init(value: 3, unit: .tablespoons)),
                    .coriander.changingServingSize(to: .grams(100)),
                    .garlic.changingServingSize(to: .init(value: 0.25, unit: .cups)),
                    .oliveOil.changingServingSize(to: .init(value: 0.5, unit: .cups)),
                    .oregano.changingServingSize(to: .init(value: 1, unit: .teaspoons)),
                    .parsley.changingServingSize(to: .init(value: 0.5, unit: .cups)),
                    .redWineVinegar.changingServingSize(to: .init(value: 2, unit: .tablespoons))
                ],
                comparison: .energy,
                canChangeQuantity: false
            ))
        }
    }

    func testIngredientTapped() async throws {
        let store = TestStore(
            initialState: MealDetails.State(meal: .chimichurri),
            reducer: {
                MealDetails()
            },
            withDependencies: {
                $0.nutritionalValuesCalculator = .zero
            }
        )
        let ingredient = Ingredient(
            food: .coriander,
            quantity: .grams(100)
        )
        await store.send(.ingredientTapped(ingredient)) {
            $0.destination = .foodDetails(.init(
                food: .coriander,
                quantity: .grams(100)
            ))
        }
    }

    func testMealForm() async throws {
        let store = TestStore(
            initialState: MealDetails.State(meal: .chimichurri),
            reducer: {
                MealDetails()
            },
            withDependencies: {
                $0.nutritionalValuesCalculator = .zero
            }
        )
        var meal = Meal.chimichurri
        meal.name = "something else"
        meal.servings = 2
        meal.ingredients = Array(meal.ingredients[1...3])
        await store.send(.editButtonTapped) {
            $0.destination = .mealForm(.init(meal: .chimichurri))
        }
        await store.send(.destination(.presented(.mealForm(.delegate(.mealSaved(meal)))))) {
            $0.meal = meal
            $0.nutritionalValuesPerTotal = .zero
            $0.nutritionalValuesPerServing = .zero
        }
    }

    func testFullFlow() async throws {
        let store = TestStore(
            initialState: MealDetails.State(meal: .chimichurri),
            reducer: {
                MealDetails()
            },
            withDependencies: {
                $0.nutritionalValuesCalculator = .zero
            }
        )
        await store.send(.nutritionalInfoButtonTapped) {
            $0.destination = .foodDetails(.init(
                food: .zero,
                quantity: .zero
            ))
        }
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
        await store.send(.editButtonTapped) {
            $0.destination = .mealForm(.init(meal: .chimichurri))
        }
        var meal = Meal.chimichurri
        meal.name = "something else"
        meal.servings = 2
        meal.ingredients = Array(meal.ingredients[1...3])
        store.dependencies.nutritionalValuesCalculator.nutritionalValuesPerServing = { _ in
                .init(
                    food: .coriander,
                    quantity: .grams(100)
                )
        }
        await store.send(.destination(.presented(.mealForm(.delegate(.mealSaved(meal)))))) {
            $0.meal = meal
            $0.nutritionalValuesPerServing = .init(
                food: .coriander,
                quantity: .grams(100)
            )
        }
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
        await store.send(.nutritionalInfoPerServingButtonTapped) {
            $0.destination = .foodDetails(.init(
                food: .coriander,
                quantity: .grams(100)
            ))
        }
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
        await store.send(.ingredientTapped(.init(food: .chiliPepper, quantity: .grams(30)))) {
            $0.destination = .foodDetails(.init(
                food: .chiliPepper,
                quantity: .grams(30)
            ))
        }
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
        await store.send(.ingredientComparisonButtonTapped) {
            $0.destination = .foodComparison(.init(
                foods: [
                    .coriander.changingServingSize(to: .grams(100)),
                    .garlic.changingServingSize(to: .init(value: 0.25, unit: .cups)),
                    .oliveOil.changingServingSize(to: .init(value: 0.5, unit: .cups))
                ],
                comparison: .energy,
                canChangeQuantity: false
            ))
        }
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
    }
}

fileprivate extension NutritionalValuesCalculator {
    static var zero: Self {
        .init(
            nutritionalValues: { _ in .zero },
            nutritionalValuesPerServing: { _ in .zero }
        )
    }
}

fileprivate extension Meal {
    static var chimichurri: Self {
        Meal(
            name: "Chimichurri",
            ingredients: [
                .init(
                    food: .chiliPepper,
                    quantity: .init(value: 3, unit: .tablespoons)
                ),
                .init(
                    food: .coriander,
                    quantity: .grams(100)
                ),
                .init(
                    food: .garlic,
                    quantity: .init(value: 0.25, unit: .cups)
                ),
                .init(
                    food: .oliveOil,
                    quantity: .init(value: 0.5, unit: .cups)
                ),
                .init(
                    food: .oregano,
                    quantity: .init(value: 1, unit: .teaspoons)
                ),
                .init(
                    food: .parsley,
                    quantity: .init(value: 0.5, unit: .cups)
                ),
                .init(
                    food: .redWineVinegar,
                    quantity: .init(value: 2, unit: .tablespoons)
                ),
            ],
            servings: 10,
            instructions: "Mix well"
        )
    }
}

fileprivate extension Ingredient {
    static var zero: Self {
        .init(
            food: .zero,
            quantity: .zero
        )
    }
}

fileprivate extension Food {
    static var zero: Self {
        .init(
            name: "",
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

    static var chiliPepper: Self {
        .init(
            id: 1,
            name: "chili pepper",
            energy: .kcal(39.4),
            fatTotal: .grams(0.4),
            fatSaturated: .zero,
            protein: .grams(1.9),
            sodium: .grams(0.008),
            potassium: .grams(0.043),
            cholesterol: .zero,
            carbohydrate: .grams(8.8),
            fiber: .grams(1.5),
            sugar: .grams(5.3)
        )
    }

    static var coriander: Self {
        .init(
            id: 2,
            name: "coriander",
            energy: .kcal(306.3),
            fatTotal: .grams(17.8),
            fatSaturated: .grams(1.1),
            protein: .grams(12.3),
            sodium: .grams(0.034),
            potassium: .grams(0.405),
            cholesterol: .zero,
            carbohydrate: .grams(55.2),
            fiber: .grams(41),
            sugar: .zero
        )
    }

    static var garlic: Self {
        .init(
            id: 3,
            name: "garlic",
            energy: .kcal(144.8),
            fatTotal: .grams(0.7),
            fatSaturated: .zero,
            protein: .grams(6.4),
            sodium: .grams(0.016),
            potassium: .grams(0.153),
            cholesterol: .zero,
            carbohydrate: .grams(32.5),
            fiber: .grams(2),
            sugar: .grams(1)
        )
    }

    static var oliveOil: Self {
        .init(
            id: 4,
            name: "olive oil",
            energy: .kcal(869.2),
            fatTotal: .grams(101.2),
            fatSaturated: .grams(13.9),
            protein: .zero,
            sodium: .milligrams(1),
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .zero,
            fiber: .zero,
            sugar: .zero
        )
    }

    static var oregano: Self {
        .init(
            id: 5,
            name: "oregano",
            energy: .kcal(269),
            fatTotal: .grams(4),
            fatSaturated: .grams(2),
            protein: .grams(9),
            sodium: .grams(0.025),
            potassium: .grams(0.147),
            cholesterol: .zero,
            carbohydrate: .grams(69.1),
            fiber: .grams(42.2),
            sugar: .grams(4)
        )
    }

    static var parsley: Self {
        .init(
            id: 6,
            name: "parsley",
            energy: .kcal(36.1),
            fatTotal: .grams(0.8),
            fatSaturated: .grams(0.3),
            protein: .grams(2.9),
            sodium: .grams(0.056),
            potassium: .grams(0.058),
            cholesterol: .zero,
            carbohydrate: .grams(6.2),
            fiber: .grams(3.5),
            sugar: .grams(0.8)
        )
    }

    static var redWineVinegar: Self {
        .init(
            id: 7,
            name: "red wine vinegar",
            energy: .kcal(18.9),
            fatTotal: .zero,
            fatSaturated: .zero,
            protein: .grams(0.1),
            sodium: .grams(0.008),
            potassium: .grams(0.007),
            cholesterol: .zero,
            carbohydrate: .grams(0.3),
            fiber: .zero,
            sugar: .zero
        )
    }
}
