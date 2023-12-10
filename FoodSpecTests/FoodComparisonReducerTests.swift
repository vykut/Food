//
//  FoodComparisonReducerTests.swift
//  FoodSpecTests
//
//  Created by Victor Socaciu on 10/12/2023.
//

import XCTest
import ComposableArchitecture
import PowerAssert
@testable import FoodSpec

@MainActor
final class FoodComparisonReducerTests: XCTestCase {
    typealias State = FoodComparisonReducer.State

    func testStateDefaultInitializer() async throws {
        let store = TestStore(
            initialState: FoodComparisonReducer.State(),
            reducer: {
                FoodComparisonReducer()
            }
        )

        store.assert {
            $0.foods = []
            $0.selectedFoodIds = []
            $0.comparedFoods = []
            $0.filterQuery = ""
            $0.isShowingComparison = false
            $0.comparison = .energy
            $0.foodSortingStrategy = .value
            $0.foodSortingOrder = .forward
        }
    }

    func testComputedProperty_filteredFoods() async throws {
        var state = FoodComparisonReducer.State(
            foods: [.ribeye, .eggplant],
            filterQuery: "e"
        )
        XCTAssertNoDifference(state.filteredFoods, [.ribeye, .eggplant])

        state = FoodComparisonReducer.State(
            foods: [.ribeye, .eggplant],
            filterQuery: "eg"
        )
        XCTAssertNoDifference(state.filteredFoods, [.eggplant])

        state = FoodComparisonReducer.State(
            foods: [.ribeye, .eggplant],
            filterQuery: ""
        )
        XCTAssertNoDifference(state.filteredFoods, [.ribeye, .eggplant])
    }

    func testComputedProperty_isCompareButtonDisabled() async throws {
        var state = State(
            selectedFoodIds: [1, 2]
        )
        XCTAssertNoDifference(state.isCompareButtonDisabled, false)

        state.selectedFoodIds = [1]
        XCTAssertNoDifference(state.isCompareButtonDisabled, true)

        state.selectedFoodIds = []
        XCTAssertNoDifference(state.isCompareButtonDisabled, true)

        state.selectedFoodIds = [1, 2, 3, 4, 5]
        XCTAssertNoDifference(state.isCompareButtonDisabled, false)
    }

    func testIsSelectionDisabled() async throws {
        let food = Food.eggplant
        var state = State(
            selectedFoodIds: []
        )
        XCTAssertNoDifference(state.isSelectionDisabled(for: food), false)

        state.selectedFoodIds = [1, 2, 3, 4]
        XCTAssertNoDifference(state.isSelectionDisabled(for: food), false)

        state.selectedFoodIds = [nil]
        XCTAssertNoDifference(state.isSelectionDisabled(for: food), false)

        state.selectedFoodIds = [nil, 1, 2, 3, 4, 5, 6]
        XCTAssertNoDifference(state.isSelectionDisabled(for: food), false)

        state.selectedFoodIds = [1, 2, 3, 4, 5, 6, 7]
        XCTAssertNoDifference(state.isSelectionDisabled(for: food), true)
    }

    func testComputedProperty_availableSortingStrategies() async throws {
        var state = State(
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
            initialState: FoodComparisonReducer.State(
                foods: [eggplant, oliveOil, ribeye] + (4...10).map { .init(id: Int64($0), name: String($0)) }
            ),
            reducer: {
                FoodComparisonReducer()
            }
        )
        await store.send(.didChangeSelection([1])) {
            $0.selectedFoodIds = [1]
        }
        await store.send(.updateFilterQuery("e")) {
            $0.filterQuery = "e"
        }
        XCTAssertNoDifference(store.state.filteredFoods, [eggplant, oliveOil, ribeye])
        await store.send(.didChangeSelection([1, 3])) {
            $0.selectedFoodIds = [1, 3]
        }
        await store.send(.updateFilterQuery("")) {
            $0.filterQuery = ""
        }
        XCTAssertNoDifference(store.state.filteredFoods, store.state.foods)
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, false)
        await store.send(.didChangeSelection([1, 3, 4, 5, 6, 7, 8])) {
            $0.selectedFoodIds = [1, 3, 4, 5, 6, 7, 8]
        }
        XCTAssertNoDifference(store.state.isSelectionDisabled(for: oliveOil), true)
        await store.send(.didChangeSelection([1, 2, 3])) {
            $0.selectedFoodIds = [1, 2, 3]
        }
        await store.send(.didTapCompare(.energy)) {
            $0.comparedFoods = [eggplant, ribeye, oliveOil]
            $0.comparison = .energy
            $0.isShowingComparison = true
        }
        await store.send(.updateSortingStrategy(.name)) {
            $0.comparedFoods = [eggplant, oliveOil, ribeye]
            $0.foodSortingStrategy = .name
        }
        await store.send(.updateSortingStrategy(.name)) {
            $0.comparedFoods = [ribeye, oliveOil, eggplant]
            $0.foodSortingStrategy = .name
            $0.foodSortingOrder = .reverse
        }
        await store.send(.updateSortingStrategy(.protein)) {
            $0.comparedFoods = [oliveOil, eggplant, ribeye]
            $0.foodSortingStrategy = .protein
            $0.foodSortingOrder = .forward
        }
        await store.send(.updateComparisonType(.fat)) {
            $0.comparedFoods = [eggplant, ribeye, oliveOil]
            $0.comparison = .fat
            $0.foodSortingStrategy = .value
            $0.foodSortingOrder = .forward
        }
        await store.send(.updateComparisonType(.macronutrients)) {
            $0.comparedFoods = [eggplant, ribeye, oliveOil]
            $0.comparison = .macronutrients
        }
    }
}

extension Food {
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
}

extension Food {
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
