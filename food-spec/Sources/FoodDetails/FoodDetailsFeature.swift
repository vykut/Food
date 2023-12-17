import Foundation
import ComposableArchitecture
import Shared
import QuantityPicker

@Reducer
public struct FoodDetailsFeature {
    @ObservableState
    public struct State: Hashable {
        let originalFood: Food
        var food: Food
        var quantityPicker: QuantityPickerFeature.State = .init()

        public init(food: Food, quantity: Quantity? = nil) {
            self.originalFood = food
            self.food = food
            if let quantity {
                self.quantityPicker = .init(quantity: quantity)
                self.food = food.changingServingSize(to: quantity)
            }
        }
    }

    @CasePathable
    public enum Action {
        case quantityPicker(QuantityPickerFeature.Action)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.quantityPicker, action: \.quantityPicker) {
            QuantityPickerFeature()
        }
        Reduce { state, action in
            switch action {
                case .quantityPicker(let action):
                    return reduce(state: &state, action: action)
            }
        }
    }

    private func reduce(state: inout State, action: QuantityPickerFeature.Action) -> Effect<Action> {
        state.food = state.originalFood.changingServingSize(to: state.quantityPicker.quantity)
        return .none
    }
}
