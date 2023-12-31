import Foundation
import ComposableArchitecture
import Shared
import QuantityPicker

@Reducer
public struct FoodDetails: Sendable {
    @ObservableState
    public struct State: Hashable {
        let originalFood: Food
        var food: Food
        var quantityPicker: QuantityPicker.State

        public init(food: Food, quantity: Quantity? = nil) {
            self.originalFood = food
            self.food = food
            if let quantity {
                self.quantityPicker = .init(id: food.id, quantity: quantity)
                self.food = food.changingServingSize(to: quantity)
            } else {
                self.quantityPicker = .init(id: food.id)
            }
        }
    }

    @CasePathable
    public enum Action {
        case quantityPicker(QuantityPicker.Action)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.quantityPicker, action: \.quantityPicker) {
            QuantityPicker()
        }
        Reduce { state, action in
            switch action {
                case .quantityPicker(let action):
                    return reduce(state: &state, action: action)
            }
        }
    }

    private func reduce(state: inout State, action: QuantityPicker.Action) -> Effect<Action> {
        state.food = state.originalFood.changingServingSize(to: state.quantityPicker.quantity)
        return .none
    }
}
