import Foundation
import XCTest
import Shared
import ComposableArchitecture
import Database
@testable import FoodSelection

@MainActor
final class FoodSelectionTests: XCTestCase {
    typealias State = FoodSelectionFeature.State

    func testComputedProperty_filteredFoods() async throws {
        var state = FoodSelectionFeature.State()
        state.foods = [.ribeye, .eggplant]
        state.filterQuery = "e"

        XCTAssertNoDifference(state.filteredFoods, [.ribeye, .eggplant])

        state = State()
        state.foods = [.ribeye, .eggplant]
        state.filterQuery = "eg"
        XCTAssertNoDifference(state.filteredFoods, [.eggplant])

        state = State()
        state.foods = [.ribeye, .eggplant]
        state.filterQuery = ""
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

    func testFullFlow() async throws {
        var eggplant = Food.eggplant
        eggplant.id = 1
        var oliveOil = Food.oliveOil
        oliveOil.id = 2
        var ribeye = Food.ribeye
        ribeye.id = 3
        let (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        let store = TestStore(
            initialState: FoodSelectionFeature.State(),
            reducer: {
                FoodSelectionFeature()
            },
            withDependencies: {
                $0.databaseClient.observeFoods = { strategy, order in
                    XCTAssertEqual(strategy.name, "name")
                    XCTAssertEqual(order, .forward)
                    return stream
                }
            }
        )
        XCTAssertEqual(store.state.shouldShowCancelButton, false)
        await store.send(.onFirstAppear)
        continuation.yield([eggplant, oliveOil, ribeye])
        await store.receive(\.updateFoods) {
            $0.foods = [eggplant, oliveOil, ribeye]
        }
        await store.send(.updateSelection([1])) {
            $0.selectedFoodIds = [1]
        }
        XCTAssertEqual(store.state.shouldShowCancelButton, true)
        await store.send(.updateFilter("e")) {
            $0.filterQuery = "e"
        }
        XCTAssertNoDifference(store.state.filteredFoods, [eggplant, oliveOil, ribeye])
        await store.send(.updateSelection([1, 3])) {
            $0.selectedFoodIds = [1, 3]
        }
        await store.send(.updateFilter("")) {
            $0.filterQuery = ""
        }
        XCTAssertNoDifference(store.state.filteredFoods, store.state.foods)
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, false)
        await store.send(.updateSelection([1, 3, 4, 5, 6, 7, 8])) {
            $0.selectedFoodIds = [1, 3, 4, 5, 6, 7, 8]
        }
        XCTAssertNoDifference(store.state.isSelectionDisabled(for: oliveOil), true)
        await store.send(.updateSelection([1, 2, 3])) {
            $0.selectedFoodIds = [1, 2, 3]
        }
        await store.send(.compareButtonTapped(.energy)) {
            $0.foodComparison = .init(
                foods: [eggplant, oliveOil, ribeye,],
                comparison: .energy,
                foodSortingStrategy: .value,
                foodSortingOrder: .forward
            )
        }
        await store.send(.foodComparison(.dismiss)) {
            $0.foodComparison = nil
        }
        continuation.yield([eggplant, oliveOil, ribeye, .preview(id: 10)])
        await store.receive(\.updateFoods) {
            $0.foods = [eggplant, oliveOil, ribeye, .preview(id: 10)]
        }
        await store.send(.cancelButtonTapped) {
            $0.selectedFoodIds = []
        }
        continuation.finish()
        await store.finish()
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
