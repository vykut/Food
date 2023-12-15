import Foundation
import Shared
import Database
import QuantityPicker
import ComposableArchitecture

@Reducer
public struct MealFormFeature {
    @ObservableState
    public struct State: Hashable {
        var meal: Meal
        var isSaveButtonDisabled: Bool

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
            self.isSaveButtonDisabled = true
        }

        public init(meal: Meal) {
            self.meal = meal
            self.isSaveButtonDisabled = false
        }
    }

    @CasePathable
    public enum Action {
        case cancelButtonTapped
        case saveButtonTapped
        case updateMeal(Meal)
        case quantityPicker(QuantityPickerFeature.Action)
        case onDeleteIngredients(IndexSet)
    }

    public init() { }

    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Scope(state: \.quantity, action: \.quantityPicker) {
            QuantityPickerFeature()
        }
        Reduce { state, action in
            switch action {
                case .cancelButtonTapped:
                    return .run { [dismiss] _ in
                        await dismiss()
                    }
                case .saveButtonTapped:
                    // store in db then dismiss the view
                    return .run { [databaseClient, dismiss, meal = state.meal] _ in
                        try await databaseClient.insert(meal: meal)
                        await dismiss()
                    }
                case .updateMeal(let meal):
                    state.meal = meal
                    if isValid(meal) {
                        state.isSaveButtonDisabled = false
                    } else {
                        state.isSaveButtonDisabled = true
                    }
                    return .none
                case .quantityPicker:
                    return .none
                case .onDeleteIngredients(let indices):
                    state.meal.ingredients.remove(atOffsets: indices)
                    return .none
            }
        }
    }

    private func isValid(_ meal: Meal) -> Bool {
        !meal.name.isEmpty &&
        !meal.ingredients.isEmpty
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
