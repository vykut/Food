import Foundation
import Shared
import XCTest
import ComposableArchitecture
@testable import MealList

@MainActor
final class MealListTests: XCTestCase {
    func testStateInitialization() async throws {
        let store = TestStore(
            initialState: MealList.State(),
            reducer: {
                MealList()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        store.assert {
            $0.mealsWithNutritionalValues = []
            $0.destination = nil
        }
        XCTAssertEqual(store.state.showsAddMealPrompt, true)
    }

    func testPlusButton() async throws {
        let store = TestStore(
            initialState: MealList.State(),
            reducer: {
                MealList()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.plusButtonTapped) {
            $0.destination = .mealForm(.init())
        }
    }

    func testMealTapped() async throws {
        let store = TestStore(
            initialState: MealList.State(),
            reducer: {
                MealList()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.mealTapped(.chimichurri)) {
            $0.destination = .mealDetails(.init(meal: .chimichurri))
        }
    }

    func testOnDelete() async throws {
        let meals: [Meal] = [
            .mock(id: 1, ingredients: [.chiliPepper, .redWineVinegar]),
            .mock(id: 2, ingredients: [.coriander, .oliveOil]),
            .mock(id: 3, ingredients: [.oregano, .parsley]),
        ]
        let store = TestStore(
            initialState: MealList.State(),
            reducer: {
                MealList()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.databaseClient.deleteMeals = { XCTAssert(meals.contains($0[0...1])) }
                $0.nutritionalValuesCalculator = .zero
            }
        )
        store.exhaustivity = .off
        await store.send(.mealObservation(.delegate(.mealsChanged(meals))))
        await store.send(.onDelete([0, 1]))
        await store.send(.mealObservation(.delegate(.mealsChanged([meals[0]]))))
        store.assert {
            $0.mealsWithNutritionalValues = [
                .init(meal: meals[0], perTotal: .zero, perServing: .zero)
            ]
        }
    }

    func testMealSaved() async throws {
        let store = TestStore(
            initialState: MealList.State(),
            reducer: {
                MealList()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.plusButtonTapped) {
            $0.destination = .mealForm(.init())
        }
        await store.send(.destination(.presented(.mealForm(.delegate(.mealSaved(.chimichurri)))))) {
            $0.destination = .mealDetails(.init(meal: .chimichurri))
        }
    }

    func testFullFlow() async throws {
        let (stream, continuation) = AsyncStream.makeStream(of: [Meal].self)
        let store = TestStore(
            initialState: MealList.State(),
            reducer: {
                MealList()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.databaseClient.observeMeals = { _, _ in stream }
                $0.databaseClient.deleteMeals = { _ in }
                $0.nutritionalValuesCalculator = .zero
            }
        )
        await store.send(.mealObservation(.startObservation))
        continuation.yield([])
        await store.receive(\.mealObservation.delegate.mealsChanged)
        XCTAssertEqual(store.state.showsAddMealPrompt, true)
        await store.send(.plusButtonTapped) {
            $0.destination = .mealForm(.init())
        }
        await store.send(.destination(.presented(.mealForm(.delegate(.mealSaved(.chimichurri)))))) {
            $0.destination = .mealDetails(.init(meal: .chimichurri))
        }
        continuation.yield([.chimichurri])
        await store.receive(\.mealObservation.delegate.mealsChanged) {
            $0.mealsWithNutritionalValues = [
                .init(meal: .chimichurri, perTotal: .zero, perServing: .zero)
            ]
        }
        XCTAssertEqual(store.state.showsAddMealPrompt, false)
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
        await store.send(.mealTapped(.chimichurri)) {
            $0.destination = .mealDetails(.init(meal: .chimichurri))
        }
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
        store.dependencies.databaseClient.getMeals = { q, s, o in
            XCTAssertEqual(q, "chim")
            XCTAssertEqual(s, .name)
            XCTAssertEqual(o, .forward)
            return [.chimichurri]
        }
        await store.send(.mealSearch(.updateFocus(true))) {
            $0.mealSearch.isFocused = true
        }
        await store.send(.mealSearch(.updateQuery("chim"))) {
            $0.mealSearch.query = "chim"
        }
        await store.receive(\.mealSearch.searchStarted) {
            $0.mealSearch.isSearching = true
        }
        await store.receive(\.mealSearch.result) {
            $0.mealSearch.searchResults = [.chimichurri]
            $0.searchResults = [
                .init(meal: .chimichurri, perTotal: .zero, perServing: .zero)
            ]
        }
        await store.receive(\.mealSearch.searchEnded) {
            $0.mealSearch.isSearching = false
        }
        await store.send(.mealSearch(.updateFocus(false))) {
            $0.mealSearch.isFocused = false
            $0.searchResults = []
            $0.mealSearch.searchResults = []
        }
        store.dependencies.databaseClient.deleteMeals = {
            XCTAssertNoDifference($0, [.chimichurri])
        }
        await store.send(.onDelete(.init(integer: 0)))
        continuation.yield([])
        await store.receive(\.mealObservation.delegate.mealsChanged) {
            $0.mealsWithNutritionalValues = []
        }
        XCTAssertEqual(store.state.showsAddMealPrompt, true)
        continuation.finish()
        await store.finish()
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

fileprivate extension Ingredient {
    static var zero: Self {
        .init(
            food: .zero,
            quantity: .zero
        )
    }
}

fileprivate extension Meal {
    static func mock(id: Int64, ingredients: [Food]) -> Self {
        .init(
            id: id,
            name: ingredients.map(\.name).joined(),
            ingredients: ingredients.map { .init(food: $0, quantity: .grams(100)) },
            servings: 1,
            instructions: ""
        )
    }

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
