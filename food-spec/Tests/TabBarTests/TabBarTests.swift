import Foundation
import Shared
import XCTest
import ComposableArchitecture
@testable import TabBar

@MainActor
final class TabBarTests: XCTestCase {
    func testUpdateTab() async throws {
        let store = TestStore(
            initialState: TabBar.State(),
            reducer: {
                TabBar()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.updateTab(.foodSelection)) {
            $0.tab = .foodSelection
        }
        await store.send(.updateTab(.foodList)) {
            $0.tab = .foodList
        }
        await store.send(.updateTab(.mealList)) {
            $0.tab = .mealList
        }
    }

    func testIntegrationWithSpotlight_delegate_showFoodDetails() async throws {
        let store = TestStore(
            initialState: TabBar.State(),
            reducer: {
                TabBar()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.spotlight(.delegate(.showFoodDetails(.chiliPepper)))) {
            $0.tab = .foodList
            $0.foodList.destination = .foodDetails(.init(food: .chiliPepper))
        }
    }

    func testIntegrationWithSpotlight_delegate_showMealDetails() async throws {
        let store = TestStore(
            initialState: TabBar.State(),
            reducer: {
                TabBar()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.spotlight(.delegate(.showMealDetails(.chimichurri)))) {
            $0.tab = .mealList
            $0.mealList.destination = .mealDetails(.init(meal: .chimichurri))
        }
    }

    func testIntegrationWithSpotlight_delegate_searchFood() async throws {
        let store = TestStore(
            initialState: TabBar.State(),
            reducer: {
                TabBar()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.continuousClock = ImmediateClock()
                $0.foodClient.getFoods = {
                    XCTAssertEqual($0, "eggplant")
                    return []
                }
                $0.databaseClient.getFoods = { q, _, _ in
                    XCTAssertEqual(q, "eggplant")
                    return []
                }
            }
        )
        await store.send(.spotlight(.delegate(.searchFood("eggplant")))) {
            $0.tab = .foodList
            $0.foodList.destination = nil
            $0.foodList.foodSearch.isFocused = true
        }
        await store.receive(\.foodList.foodSearch.updateQuery) {
            $0.foodList.foodSearch.query = "eggplant"
        }
        await store.receive(\.foodList.foodSearch.searchStarted) {
            $0.foodList.foodSearch.isSearching = true
        }
        await store.receive(\.foodList.foodSearch.result)
        await store.receive(\.foodList.foodSearch.searchEnded) {
            $0.foodList.foodSearch.isSearching = false
        }
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
            id: 1,
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
