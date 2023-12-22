import Foundation
import XCTest
import Shared
import ComposableArchitecture
import Database
@testable import FoodSelection

@MainActor
final class FoodSelectionTests: XCTestCase {
    typealias State = FoodSelection.State

    func testComputedProperty_isCompareButtonDisabled() async throws {
        let store = TestStore(
            initialState: State(selectedFoodIds: [1, 2]),
            reducer: {
                FoodSelection()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, false)

        await store.send(.updateSelection([1])) {
            $0.selectedFoodIds = [1]
        }
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, true)

        await store.send(.updateSelection([])) {
            $0.selectedFoodIds = []
        }
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, true)

        await store.send(.updateSelection([1, 2, 3, 4, 5])) {
            $0.selectedFoodIds = [1, 2, 3, 4, 5]
        }
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, false)
    }

    func testIsSelectionDisabled() async throws {
        let store = TestStore(
            initialState: State(selectedFoodIds: []),
            reducer: {
                FoodSelection()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        let food = Food.eggplant
        XCTAssertNoDifference(store.state.isSelectionDisabled(for: food), false)

        await store.send(.updateSelection([1, 2, 3, 4])) {
            $0.selectedFoodIds = [1, 2, 3, 4]
        }
        XCTAssertNoDifference(store.state.isSelectionDisabled(for: food), false)

        await store.send(.updateSelection([nil])) {
            $0.selectedFoodIds = [nil]
        }
        XCTAssertNoDifference(store.state.isSelectionDisabled(for: food), false)

        await store.send(.updateSelection([nil, 1, 2, 3, 4, 5, 6])) {
            $0.selectedFoodIds = [nil, 1, 2, 3, 4, 5, 6]
        }
        XCTAssertNoDifference(store.state.isSelectionDisabled(for: food), false)

        await store.send(.updateSelection([1, 2, 3, 4, 5, 6, 7])) {
            $0.selectedFoodIds = [1, 2, 3, 4, 5, 6, 7]
        }
        XCTAssertNoDifference(store.state.isSelectionDisabled(for: food), true)
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
            initialState: FoodSelection.State(),
            reducer: {
                FoodSelection()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        XCTAssertEqual(store.state.shouldShowCancelButton, false)
        await store.send(.updateSelection([1])) {
            $0.selectedFoodIds = [1]
        }
        XCTAssertEqual(store.state.shouldShowCancelButton, true)
        await store.send(.updateSelection([1, 3])) {
            $0.selectedFoodIds = [1, 3]
        }
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, false)
        await store.send(.updateSelection([1, 3, 4, 5, 6, 7, 8])) {
            $0.selectedFoodIds = [1, 3, 4, 5, 6, 7, 8]
        }
        XCTAssertNoDifference(store.state.isSelectionDisabled(for: oliveOil), true)
        await store.send(.updateSelection([1, 2, 3])) {
            $0.selectedFoodIds = [1, 2, 3]
        }
        await store.send(.foodSearch(.foodObservation(.updateFoods([eggplant, oliveOil, ribeye])))) {
            $0.foodSearch.foodObservation.foods = [eggplant, oliveOil, ribeye]
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
