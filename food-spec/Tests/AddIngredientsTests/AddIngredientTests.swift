import Foundation
import Shared
import XCTest
import ComposableArchitecture
@testable import AddIngredients

@MainActor
final class AddIngredientTests: XCTestCase {
    func testStateInitializers() async throws {
        var store = TestStore(
            initialState: AddIngredients.State(ingredients: []),
            reducer: {
                AddIngredients()
            }
        )
        store.assert { state in
            state.initialIngredients = []
            state.ingredientPickers = .init(id: \.food.id)
        }
        XCTAssertNoDifference(store.state.selectedIngredients, [])

        let ingredients = Meal.chimichurri.ingredients
        store = TestStore(
            initialState: AddIngredients.State(ingredients: ingredients),
            reducer: {
                AddIngredients()
            }
        )
        store.assert { state in
            state.initialIngredients = ingredients
            state.ingredientPickers = .init(
                uniqueElements: ingredients.map {
                    .init(food: $0.food, quantity: $0.quantity)
                },
                id: \.food.id
            )
        }
        XCTAssertNoDifference(store.state.selectedIngredients, ingredients)
    }

    func testOnFirstAppear() async throws {
        var store = TestStore(
            initialState: AddIngredients.State(ingredients: []),
            reducer: {
                AddIngredients()
            },
            withDependencies: {
                $0.databaseClient.getRecentFoods = { sortedBy, order in
                    XCTAssertEqual(sortedBy.name, "name")
                    XCTAssertEqual(order, .forward)
                    return [.chiliPepper, .coriander, .garlic]
                }
            }
        )
        await store.send(.onFirstAppear)
        await store.receive(\.updateFoods) {
            $0.ingredientPickers = .init(
                uniqueElements: [
                    .init(food: .chiliPepper),
                    .init(food: .coriander),
                    .init(food: .garlic),
                ],
                id: \.food.id)
        }
        XCTAssertNoDifference(store.state.selectedIngredients, [])

        store = TestStore(
            initialState: AddIngredients.State(
                ingredients: [
                    .init(
                        food: .oliveOil,
                        quantity: .init(value: 0.5, unit: .cups)
                    ),
                    .init(
                        food: .oregano,
                        quantity: .init(value: 1, unit: .teaspoons)
                    ),
                ]
            ),
            reducer: {
                AddIngredients()
            },
            withDependencies: {
                $0.databaseClient.getRecentFoods = { sortedBy, order in
                    XCTAssertEqual(sortedBy.name, "name")
                    XCTAssertEqual(order, .forward)

                    return [.chiliPepper, .coriander, .garlic, .oliveOil, .oregano]
                }
            }
        )
        await store.send(.onFirstAppear)
        await store.receive(\.updateFoods) {
            $0.ingredientPickers = .init(
                uniqueElements: [
                    .init(
                        food: .oliveOil,
                        quantity: .init(value: 0.5, unit: .cups)
                    ),
                    .init(
                        food: .oregano,
                        quantity: .init(value: 1, unit: .teaspoons)
                    ),
                    .init(food: .chiliPepper),
                    .init(food: .coriander),
                    .init(food: .garlic),
                ],
                id: \.food.id
            )
        }
        XCTAssertNoDifference(
            store.state.selectedIngredients,
            [
                .init(
                    food: .oliveOil,
                    quantity: .init(value: 0.5, unit: .cups)
                ),
                .init(
                    food: .oregano,
                    quantity: .init(value: 1, unit: .teaspoons)
                ),
            ]
        )
    }

    func testDoneButton() async throws {
        let store = TestStore(
            initialState: AddIngredients.State(ingredients: []),
            reducer: {
                AddIngredients()
            },
            withDependencies: {
                $0.dismiss = .init {
                    XCTAssert(true)
                }
            }
        )
        await store.send(.doneButtonTapped)
    }

    func testIntegrationWithIngredientPickers() async throws {
        let store = TestStore(
            initialState: AddIngredients.State(
                ingredients: [
                    .init(
                        food: .oliveOil,
                        quantity: .init(value: 0.5, unit: .cups)
                    ),
                    .init(
                        food: .oregano,
                        quantity: .init(value: 1, unit: .teaspoons)
                    ),
                ]
            ),
            reducer: {
                AddIngredients()
            },
            withDependencies: {
                $0.databaseClient.getRecentFoods = { sortedBy, order in
                    XCTAssertEqual(sortedBy.name, "name")
                    XCTAssertEqual(order, .forward)

                    return [.chiliPepper, .coriander, .garlic, .oliveOil, .oregano]
                }
            }
        )
        await store.send(.onFirstAppear)
        await store.receive(\.updateFoods) {
            $0.ingredientPickers = .init(
                uniqueElements: [
                    .init(
                        food: .oliveOil,
                        quantity: .init(value: 0.5, unit: .cups)
                    ),
                    .init(
                        food: .oregano,
                        quantity: .init(value: 1, unit: .teaspoons)
                    ),
                    .init(food: .chiliPepper),
                    .init(food: .coriander),
                    .init(food: .garlic),
                ],
                id: \.food.id
            )
        }
        await store.send(.ingredientPickers(.element(id: 4, action: .updateSelection(false)))) {
            $0.ingredientPickers[id: 4]?.isSelected = false
        }
        XCTAssertNoDifference(
            store.state.selectedIngredients,
            [
                .init(
                    food: .oregano,
                    quantity: .init(value: 1, unit: .teaspoons)
                ),
            ]
        )
        await store.send(.ingredientPickers(.element(id: 1, action: .updateSelection(true)))) {
            $0.ingredientPickers[id: 1]?.isSelected = true
        }
        await store.send(.ingredientPickers(.element(id: 1, action: .quantityPicker(.updateUnit(.tablespoons))))) {
            $0.ingredientPickers[id: 1]?.quantityPicker.quantity = .init(value: 1, unit: .tablespoons)
        }
        await store.send(.ingredientPickers(.element(id: 1, action: .quantityPicker(.incrementButtonTapped)))){
            $0.ingredientPickers[id: 1]?.quantityPicker.quantity.value = 1.5
        }
        await store.send(.ingredientPickers(.element(id: 1, action: .quantityPicker(.updateValue(3))))){
            $0.ingredientPickers[id: 1]?.quantityPicker.quantity.value = 3
        }
        XCTAssertNoDifference(
            store.state.selectedIngredients,
            [
                .init(
                    food: .oregano,
                    quantity: .init(value: 1, unit: .teaspoons)
                ),
                .init(
                    food: .chiliPepper,
                    quantity: .init(value: 3, unit: .tablespoons)
                ),
            ]
        )
    }

    func testFullFlow() async throws {
        let store = TestStore(
            initialState: AddIngredients.State(
                ingredients: [
                    .init(
                        food: .oliveOil,
                        quantity: .init(value: 0.5, unit: .cups)
                    ),
                    .init(
                        food: .oregano,
                        quantity: .init(value: 1, unit: .teaspoons)
                    ),
                ]
            ),
            reducer: {
                AddIngredients()
            },
            withDependencies: {
                $0.databaseClient.getRecentFoods = { sortedBy, order in
                    XCTAssertEqual(sortedBy.name, "name")
                    XCTAssertEqual(order, .forward)

                    return [.chiliPepper, .coriander, .garlic, .oliveOil, .oregano]
                }
                $0.dismiss = .init {
                    XCTAssert(true)
                }
            }
        )
        store.exhaustivity = .off
        await store.send(.onFirstAppear)
        await store.receive(\.updateFoods)
        await store.send(.ingredientPickers(.element(id: 4, action: .updateSelection(false))))
        await store.send(.ingredientPickers(.element(id: 1, action: .updateSelection(true))))
        await store.send(.ingredientPickers(.element(id: 1, action: .quantityPicker(.updateUnit(.tablespoons)))))
        await store.send(.ingredientPickers(.element(id: 1, action: .quantityPicker(.incrementButtonTapped))))
        await store.send(.ingredientPickers(.element(id: 1, action: .quantityPicker(.updateValue(3)))))
        await store.send(.doneButtonTapped)
        XCTAssertNoDifference(
            store.state.selectedIngredients,
            [
                .init(
                    food: .oregano,
                    quantity: .init(value: 1, unit: .teaspoons)
                ),
                .init(
                    food: .chiliPepper,
                    quantity: .init(value: 3, unit: .tablespoons)
                ),
            ]
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

fileprivate extension Food {
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
