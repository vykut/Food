import Foundation
import Shared
import XCTest
import ComposableArchitecture
@testable import MealForm

@MainActor
final class MealFormTests: XCTestCase {
    func testStateInitializers() async throws {
        var store = TestStore(
            initialState: MealForm.State(),
            reducer: {
                MealForm()
            }
        )
        store.assert { state in
            state.meal = .init(name: "", ingredients: [], servings: 1, instructions: "")
            state.isEdit = false
        }
        XCTAssertNoDifference(store.state.shownIngredients, [])
        XCTAssertNoDifference(store.state.shouldShowShowAllIngredientsButton, false)
        XCTAssertNoDifference(store.state.isSaveButtonDisabled, true)
        XCTAssertNoDifference(store.state.isMealValid, false)

        store = TestStore(
            initialState: MealForm.State(meal: .chimichurri),
            reducer: {
                MealForm()
            }
        )
        store.assert { state in
            state.meal = .chimichurri
            state.isEdit = true
        }
        XCTAssertNoDifference(
            store.state.shownIngredients,
            [
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
            ]
        )
        XCTAssertNoDifference(store.state.shouldShowShowAllIngredientsButton, true)
        XCTAssertNoDifference(store.state.isSaveButtonDisabled, false)
        XCTAssertNoDifference(store.state.isMealValid, true)
    }

    func testCancelButton() async throws {
        let store = TestStore(
            initialState: MealForm.State(),
            reducer: {
                MealForm()
            },
            withDependencies: {
                $0.dismiss = . init {
                    XCTAssert(true)
                }
            }
        )
        await store.send(.cancelButtonTapped)
    }

    func testSaveButton() async throws {
        let store = TestStore(
            initialState: MealForm.State(meal: .chimichurri),
            reducer: {
                MealForm()
            },
            withDependencies: {
                $0.databaseClient.insertMeal = {
                    XCTAssertNoDifference($0, .chimichurri)
                    return .chimichurri
                }
                $0.dismiss = .init {
                    XCTAssert(true)
                }
            }
        )
        await store.send(.saveButtonTapped)
        await store.receive(\.delegate.mealSaved)

        store.dependencies.databaseClient.insertMeal = { _ in
            struct InsertionFailure: Error { }
            throw InsertionFailure()
        }
        store.dependencies.dismiss = .init { XCTFail() }
        await store.send(.saveButtonTapped)
    }

    func testAddIngredientsButton() async throws {
        var store = TestStore(
            initialState: MealForm.State(),
            reducer: {
                MealForm()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.addIngredientsButtonTapped) {
            $0.addIngredients = .init()
        }

        store = TestStore(
            initialState: MealForm.State(meal: .chimichurri),
            reducer: {
                MealForm()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.addIngredientsButtonTapped) {
            $0.addIngredients = .init(ingredients: Meal.chimichurri.ingredients)
        }
    }

    func testIngredientTapped() async throws {
        let store = TestStore(
            initialState: MealForm.State(meal: .chimichurri),
            reducer: {
                MealForm()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.ingredientTapped(store.state.meal.ingredients[0])) {
            $0.addIngredients = .init(ingredients: Meal.chimichurri.ingredients)
        }
    }

    func testUpdateMeal() async throws {
        let store = TestStore(
            initialState: MealForm.State(),
            reducer: {
                MealForm()
            }
        )
        await store.send(.updateMeal(.chimichurri)) {
            $0.meal = .chimichurri
        }
        XCTAssertEqual(store.state.isMealValid, true)
    }

    func testServings() async throws {
        let store = TestStore(
            initialState: MealForm.State(),
            reducer: {
                MealForm()
            }
        )
        await store.send(.servingsIncrementButtonTapped) {
            $0.meal.servings = 1.5
        }
        await store.send(.servingsIncrementButtonTapped) {
            $0.meal.servings = 2
        }
        await store.send(.servingsDecrementButtonTapped) {
            $0.meal.servings = 1.5
        }
        await store.send(.servingsDecrementButtonTapped) {
            $0.meal.servings = 1
        }
        await store.send(.servingsDecrementButtonTapped) {
            $0.meal.servings = 0.5
        }
        await store.send(.servingsDecrementButtonTapped)
    }

    func testDeleteIngredients() async throws {
        let store = TestStore(
            initialState: MealForm.State(meal: .chimichurri),
            reducer: {
                MealForm()
            }
        )
        await store.send(.onDeleteIngredients([0, 1, 2, 3])) {
            $0.meal.ingredients = [
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
            ]
        }
        XCTAssertNoDifference(store.state.shownIngredients, store.state.meal.ingredients)
        XCTAssertEqual(store.state.shouldShowShowAllIngredientsButton, false)
    }

    func testShowAllIngredientsButton() async throws {
        let store = TestStore(
            initialState: MealForm.State(meal: .chimichurri),
            reducer: {
                MealForm()
            }
        )
        await store.send(.showAllIngredientsButtonTapped) {
            $0.showsAllIngredients = true
        }
        XCTAssertEqual(store.state.shouldShowShowAllIngredientsButton, false)
        XCTAssertNoDifference(
            store.state.shownIngredients,
            Meal.chimichurri.ingredients
        )
    }

    func testIntegrationWithAddIngredients() async throws {
        let store = TestStore(
            initialState: MealForm.State(),
            reducer: {
                MealForm()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.addIngredientsButtonTapped) {
            $0.addIngredients = .init()
        }
        store.exhaustivity = .off
        await store.send(.addIngredients(.presented(.foodSearch(.foodObservation(.updateFoods([.chiliPepper, .coriander, .garlic, .oliveOil, .oregano, .parsley, .redWineVinegar]))))))
        await store.send(.addIngredients(.presented(.ingredientPickers(.element(id: 1, action: .updateSelection(true))))))
        await store.send(.addIngredients(.presented(.ingredientPickers(.element(id: 2, action: .updateSelection(true))))))
        await store.send(.addIngredients(.presented(.ingredientPickers(.element(id: 3, action: .updateSelection(true))))))
        await store.send(.addIngredients(.presented(.ingredientPickers(.element(id: 4, action: .updateSelection(true))))))
        await store.send(.addIngredients(.presented(.ingredientPickers(.element(id: 4, action: .quantityPicker(.updateUnit(.cups)))))))
        await store.send(.addIngredients(.presented(.ingredientPickers(.element(id: 1, action: .updateSelection(false))))))
        store.exhaustivity = .on
        await store.send(.addIngredients(.dismiss)) {
            $0.meal.ingredients = [
                .init(food: .coriander, quantity: .grams(100)),
                .init(food: .garlic, quantity: .grams(100)),
                .init(food: .oliveOil, quantity: .init(value: 1, unit: .cups)),
            ]
            $0.addIngredients = nil
        }
        XCTAssertNoDifference(
            store.state.shownIngredients,
            [
                .init(food: .coriander, quantity: .grams(100)),
                .init(food: .garlic, quantity: .grams(100)),
                .init(food: .oliveOil, quantity: .init(value: 1, unit: .cups)),
            ]
        )
        XCTAssertEqual(store.state.shouldShowShowAllIngredientsButton, false)
        XCTAssertEqual(store.state.isSaveButtonDisabled, true)
        XCTAssertEqual(store.state.isMealValid, false)
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
