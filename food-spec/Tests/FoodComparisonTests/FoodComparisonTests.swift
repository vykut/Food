import XCTest
import ComposableArchitecture
import Shared
@testable import FoodComparison

@MainActor
final class FoodComparisonReducerTests: XCTestCase {
    typealias State = FoodComparison.State

    func testStateDefaultInitializer() async throws {
        let store = TestStore(
            initialState: FoodComparison.State(
                foods: [.preview(id: 1), .preview(id: 2)],
                comparison: .energy
            ),
            reducer: {
                FoodComparison()
            }
        )

        store.assert {
            $0.originalFoods = [.preview(id: 1), .preview(id: 2)]
            $0.comparison = .energy
            $0.foodSortingStrategy = .value
            $0.foodSortingOrder = .forward
        }
    }

    func testComputedProperty_availableSortingStrategies() async throws {
        var state = State(
            foods: [],
            comparison: .energy
        )

        XCTAssertNoDifference(state.availableSortingStrategies, State.SortingStrategy.allCases)

        state.comparison = .macronutrients
        XCTAssertNoDifference(state.availableSortingStrategies, State.SortingStrategy.allCases)

        for comparison in Set(Comparison.allCases).symmetricDifference([.energy, .macronutrients]) {
            state.comparison = comparison
            XCTAssertNoDifference(state.availableSortingStrategies, [.name, .value])
        }
    }

    func testSorting_withStrategy_andComparison() async throws {
        let foods: [Food] = [.eggplant, .ribeye, .oliveOil]
        XCTAssertNoDifference(foods.sorted(by: .name, comparison: .energy, order: .forward), [.eggplant, .oliveOil, .ribeye])
        XCTAssertNoDifference(foods.sorted(by: .name, comparison: .energy, order: .reverse), [.ribeye, .oliveOil, .eggplant])
        XCTAssertNoDifference(foods.sorted(by: .name, comparison: .protein, order: .forward), [.eggplant, .oliveOil, .ribeye])
        XCTAssertNoDifference(foods.sorted(by: .protein, comparison: .potassium, order: .forward), [.oliveOil, .eggplant, .ribeye])
        XCTAssertNoDifference(foods.sorted(by: .carbohydrate, comparison: .potassium, order: .forward), [.ribeye, .oliveOil, .eggplant])
        XCTAssertNoDifference(foods.sorted(by: .fat, comparison: .potassium, order: .forward), [.eggplant, .ribeye, .oliveOil])
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .energy, order: .forward),
            foods.sorted(by: .energy, order: .forward)
        )
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .protein, order: .forward),
            foods.sorted(by: .protein, order: .forward)
        )
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .carbohydrate, order: .forward),
            foods.sorted(by: .carbohydrate, order: .forward)
        )
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .fiber, order: .forward),
            foods.sorted(by: .fiber, order: .forward)
        )
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .sugar, order: .forward),
            foods.sorted(by: .sugar, order: .forward)
        )
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .fat, order: .forward),
            foods.sorted(by: .fat, order: .forward)
        )
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .saturatedFat, order: .forward),
            foods.sorted(by: .saturatedFat, order: .forward)
        )
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .cholesterol, order: .forward),
            foods.sorted(by: .cholesterol, order: .forward)
        )
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .potassium, order: .forward),
            foods.sorted(by: .potassium, order: .forward)
        )
        XCTAssertNoDifference(
            foods.sorted(by: .value, comparison: .sodium, order: .forward),
            foods.sorted(by: .sodium, order: .forward)
        )
    }

    func testSorting_withComparison() async throws {
        let foods: [Food] = [.eggplant, .ribeye, .oliveOil]

        XCTAssertNoDifference(foods.sorted(by: .energy, order: .forward), [.eggplant, .ribeye, .oliveOil])
        XCTAssertNoDifference(foods.sorted(by: .protein, order: .forward), [.oliveOil, .eggplant, .ribeye])
        XCTAssertNoDifference(foods.sorted(by: .carbohydrate, order: .forward), [.ribeye, .oliveOil, .eggplant])
        XCTAssertNoDifference(foods.sorted(by: .fiber, order: .forward), [.ribeye, .oliveOil, .eggplant])
        XCTAssertNoDifference(foods.sorted(by: .sugar, order: .forward), [.ribeye, .oliveOil, .eggplant])
        XCTAssertNoDifference(foods.sorted(by: .fat, order: .forward), [.eggplant, .ribeye, .oliveOil])
        XCTAssertNoDifference(foods.sorted(by: .saturatedFat, order: .forward), [.eggplant, .ribeye, .oliveOil])
        XCTAssertNoDifference(foods.sorted(by: .cholesterol, order: .forward), [.eggplant, .oliveOil, .ribeye])
        XCTAssertNoDifference(foods.sorted(by: .potassium, order: .forward), [.oliveOil, .eggplant, .ribeye])
        XCTAssertNoDifference(foods.sorted(by: .sodium, order: .forward), [.eggplant, .oliveOil, .ribeye])

        XCTAssertNoDifference(foods.sorted(by: .energy, order: .reverse), [.oliveOil, .ribeye, .eggplant])
        XCTAssertNoDifference(foods.sorted(by: .protein, order: .reverse), [.ribeye, .eggplant, .oliveOil])
        XCTAssertNoDifference(foods.sorted(by: .carbohydrate, order: .reverse), [.eggplant, .ribeye, .oliveOil])
        XCTAssertNoDifference(foods.sorted(by: .fiber, order: .reverse), [.eggplant, .ribeye, .oliveOil])
        XCTAssertNoDifference(foods.sorted(by: .sugar, order: .reverse), [.eggplant, .ribeye, .oliveOil])
        XCTAssertNoDifference(foods.sorted(by: .fat, order: .reverse), [.oliveOil, .ribeye, .eggplant])
        XCTAssertNoDifference(foods.sorted(by: .saturatedFat, order: .reverse), [.oliveOil, .ribeye, .eggplant])
        XCTAssertNoDifference(foods.sorted(by: .cholesterol, order: .reverse), [.ribeye, .eggplant, .oliveOil])
        XCTAssertNoDifference(foods.sorted(by: .potassium, order: .reverse), [.ribeye, .eggplant, .oliveOil])
        XCTAssertNoDifference(foods.sorted(by: .sodium, order: .reverse), [.ribeye, .oliveOil, .eggplant])
    }

    func testFoodMacronutrients() async throws {
        XCTAssertNoDifference(Food.eggplant.macronutrients, .init(value: 9.7, unit: .grams))
        XCTAssertNoDifference(Food.oliveOil.macronutrients, .init(value: 101.2, unit: .grams))
        XCTAssertNoDifference(Food.ribeye.macronutrients, .init(value: 43.7, unit: .grams))
    }

    func testFullFlow() async throws {
        var eggplant = Food.eggplant
        eggplant.id = 1
        var oliveOil = Food.oliveOil
        oliveOil.id = 2
        var ribeye = Food.ribeye
        ribeye.id = 3
        let store = TestStore(
            initialState: FoodComparison.State(
                foods: [eggplant, oliveOil, ribeye],
                comparison: .energy
            ),
            reducer: {
                FoodComparison()
            }
        )

        await store.send(.updateSortingStrategy(.name)) {
            $0.foodSortingStrategy = .name
        }
        XCTAssertNoDifference(store.state.comparedFoods, [eggplant, oliveOil, ribeye])
        await store.send(.updateSortingStrategy(.name)) {
            $0.foodSortingStrategy = .name
            $0.foodSortingOrder = .reverse
        }
        XCTAssertNoDifference(store.state.comparedFoods, [ribeye, oliveOil, eggplant])
        await store.send(.updateSortingStrategy(.protein)) {
            $0.foodSortingStrategy = .protein
            $0.foodSortingOrder = .forward
        }
        XCTAssertNoDifference(store.state.comparedFoods, [oliveOil, eggplant, ribeye])
        await store.send(.updateComparisonType(.fat)) {
            $0.comparison = .fat
            $0.foodSortingStrategy = .value
            $0.foodSortingOrder = .forward
        }
        XCTAssertNoDifference(store.state.comparedFoods, [eggplant, ribeye, oliveOil])
        await store.send(.updateComparisonType(.macronutrients)) {
            $0.comparison = .macronutrients
        }
        XCTAssertNoDifference(store.state.comparedFoods, [eggplant, ribeye, oliveOil])
        await store.send(.quantityPicker(.incrementButtonTapped)) {
            $0.quantityPicker?.quantity.value = 110
        }
    }

    func testIntegration_withQuantityPicker() async throws {
        let store = TestStore(
            initialState: FoodComparison.State(
                foods: [.preview],
                comparison: .energy
            ),
            reducer: {
                FoodComparison()
            }
        )

        await store.send(.quantityPicker(.updateValue(200))) {
            $0.quantityPicker?.quantity.value = 200
        }
        XCTAssertNoDifference(
            store.state.comparedFoods,
            [
                .init(
                    name: "eggplant",
                    energy: .kcal(69.4),
                    fatTotal: .grams(0.4),
                    fatSaturated: .zero,
                    protein: .grams(1.6),
                    sodium: .milligrams(0),
                    potassium: .milligrams(30),
                    cholesterol: .milligrams(0),
                    carbohydrate: .grams(17.4),
                    fiber: .grams(5),
                    sugar: .grams(6.4)
                )
            ]
        )
        await store.send(.quantityPicker(.updateUnit(.pounds))) {
            $0.quantityPicker?.quantity = .init(value: 1, unit: .pounds)
        }
    }
}

fileprivate extension Food {
    init(id: Int64, name: String) {
        self.init(
            id: id,
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

fileprivate extension Food {
    static var oliveOil: Self {
        .init(
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

    static var ribeye: Self {
        .init(
            name: "ribeye",
            energy: .kcal(274.1),
            fatTotal: .grams(18.9),
            fatSaturated: .grams(8.5),
            protein: .grams(24.8),
            sodium: .milligrams(58.0),
            potassium: .milligrams(166.0),
            cholesterol: .milligrams(78),
            carbohydrate: .grams(0),
            fiber: .grams(0),
            sugar: .grams(0)
        )
    }

    static var eggplant: Self {
        .init(
            name: "eggplant",
            energy: .kcal(34.7),
            fatTotal: .grams(0.2),
            fatSaturated: .grams(0),
            protein: .grams(0.8),
            sodium: .milligrams(0),
            potassium: .milligrams(15.0),
            cholesterol: .milligrams(0),
            carbohydrate: .grams(8.7),
            fiber: .grams(2.5),
            sugar: .grams(3.2)
        )
    }
}
