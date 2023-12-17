import Foundation
import Shared
import QuantityPicker
import ComposableArchitecture

@Reducer
public struct IngredientPickerFeature {
    @ObservableState
    public struct State: Hashable {
        public var food: Food
        public var quantityPicker: QuantityPickerFeature.State
        public var isSelected: Bool

        public var ingredient: Ingredient {
            .init(
                food: food,
                quantity: quantityPicker.quantity
            )
        }

        public init(food: Food) {
            self.food = food
            self.quantityPicker = .init()
            self.isSelected = false
        }

        public init(
            food: Food,
            quantity: Quantity
        ) {
            self.food = food
            self.quantityPicker = .init(quantity: quantity)
            self.isSelected = true
        }
    }

    @CasePathable
    public enum Action {
        case quantityPicker(QuantityPickerFeature.Action)
        case updateSelection(Bool)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.quantityPicker, action: \.quantityPicker) {
            QuantityPickerFeature()
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
