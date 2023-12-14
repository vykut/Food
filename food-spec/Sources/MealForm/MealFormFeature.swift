import Foundation
import Shared
import QuantityPicker
import ComposableArchitecture

@Reducer
public struct MealFormFeature {
    @ObservableState
    public struct State: Hashable {
        var meal: Meal

        var quantity: QuantityPickerFeature.State {
            get {
                .init(quantity: meal.servingSize)
            }
            set {
                meal.servingSize = newValue.quantity
            }
        }

        public init() {
            self.meal = .empty
        }

        public init(meal: Meal) {
            self.meal = meal
        }
    }

    @CasePathable
    public enum Action {
        case updateMeal(Meal)
        case quantityPicker(QuantityPickerFeature.Action)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.quantity, action: \.quantityPicker) {
            QuantityPickerFeature()
        }
        Reduce { state, action in
            switch action {
                case .updateMeal(let meal):
                    state.meal = meal
                    return .none
                case .quantityPicker:
                    return .none
            }
        }
    }
}

fileprivate extension Meal {
    static var empty: Self {
        .init(
            name: "",
            ingredients: [],
            servingSize: .grams(100),
            instructions: ""
        )
    }
}
