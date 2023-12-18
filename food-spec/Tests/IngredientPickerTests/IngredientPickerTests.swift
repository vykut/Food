import Foundation
import XCTest
import ComposableArchitecture
@testable import IngredientPicker

@MainActor
final class IngredientPickerTests: XCTestCase {
    func testStateInitializers() async throws {
        var store = TestStore(
            initialState: IngredientPicker.State(food: .preview),
            reducer: {
                IngredientPicker()
            }
        )
        store.assert { state in
            state.food = .preview
            state.quantityPicker = .init(id: nil)
            state.isSelected = false
        }
        XCTAssertNoDifference(
            store.state.ingredient,
            .init(food: .preview, quantity: .grams(100))
        )

        store = TestStore(
            initialState: IngredientPicker.State(
                food: .preview,
                quantity: .init(value: 5.5, unit: .ounces)
            ),
            reducer: {
                IngredientPicker()
            }
        )
        store.assert { state in
            state.food = .preview
            state.quantityPicker = .init(id: nil, quantity: .init(value: 5.5, unit: .ounces))
            state.isSelected = true
        }
        XCTAssertNoDifference(
            store.state.ingredient,
            .init(food: .preview, quantity: .init(value: 5.5, unit: .ounces))
        )
    }

    func testUpdateSelection() async throws {
        let store = TestStore(
            initialState: IngredientPicker.State(food: .preview),
            reducer: {
                IngredientPicker()
            }
        )
        await store.send(.updateSelection(true)) {
            $0.isSelected = true
        }
        await store.send(.updateSelection(false)) {
            $0.isSelected = false
        }
    }

    func testIntegrationWithQuantityPicker() async throws {
        let store = TestStore(
            initialState: IngredientPicker.State(food: .preview),
            reducer: {
                IngredientPicker()
            }
        )
        await store.send(.updateSelection(true)) {
            $0.isSelected = true
        }
        await store.send(.quantityPicker(.updateUnit(.cups))) {
            $0.quantityPicker.quantity = .init(value: 1, unit: .cups)
        }
        XCTAssertNoDifference(
            store.state.ingredient,
            .init(food: .preview, quantity: .init(value: 1, unit: .cups))
        )
        await store.send(.quantityPicker(.updateValue(3))) {
            $0.quantityPicker.quantity.value = 3
        }
        XCTAssertNoDifference(
            store.state.ingredient,
            .init(food: .preview, quantity: .init(value: 3, unit: .cups))
        )
    }
}
