import Foundation
import Shared
import QuantityPicker
import ComposableArchitecture

@Reducer
public struct IngredientPicker: Sendable {
    @ObservableState
    public struct State: Hashable {
        public var food: Food
        public var quantityPicker: QuantityPicker.State
        public var isSelected: Bool

        public var ingredient: Ingredient {
            .init(
                food: food,
                quantity: quantityPicker.quantity
            )
        }

        public init(food: Food) {
            self.food = food
            self.quantityPicker = .init(id: food.id)
            self.isSelected = false
        }

        public init(
            food: Food,
            quantity: Quantity
        ) {
            self.food = food
            self.quantityPicker = .init(id: food.id, quantity: quantity)
            self.isSelected = true
        }
    }

    @CasePathable
    public enum Action {
        case quantityPicker(QuantityPicker.Action)
        case updateSelection(Bool)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.quantityPicker, action: \.quantityPicker) {
            QuantityPicker()
        }
        Reduce { state, action in
            switch action {
                case .updateSelection(let selected):
                    state.isSelected = selected
                    return .none

                case .quantityPicker:
                    return .none
            }
        }
    }
}
