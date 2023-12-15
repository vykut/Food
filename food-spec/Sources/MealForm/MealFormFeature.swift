import Foundation
import Shared
import Database
import QuantityPicker
import AddIngredients
import ComposableArchitecture

@Reducer
public struct MealFormFeature {
    @ObservableState
    public struct State: Hashable {
        var meal: Meal
        var showsAllIngredients: Bool = false
        @Presents var addIngredients: AddIngredientsFeature.State?

        var shownIngredients: [Ingredient] {
            if showsAllIngredients {
                meal.ingredients
            } else if meal.ingredients.count <= 5 {
                meal.ingredients
            } else {
                Array(meal.ingredients[0...2])
            }
        }

        var quantity: QuantityPickerFeature.State {
            get {
                .init(quantity: meal.servingSize)
            }
            set {
                meal.servingSize = newValue.quantity
            }
        }

        var shouldShowShowAllIngredientsButton: Bool {
            !showsAllIngredients &&
            meal.ingredients.count > 5
        }

        var isSaveButtonDisabled: Bool {
            !isMealValid
        }

        private var isMealValid: Bool {
            !meal.name.isEmpty &&
            !meal.ingredients.isEmpty
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
        case cancelButtonTapped
        case saveButtonTapped
        case addIngredientButtonTapped
        case updateMeal(Meal)
        case quantityPicker(QuantityPickerFeature.Action)
        case onDeleteIngredients(IndexSet)
        case showAllIngredientsButtonTapped
        case addIngredients(PresentationAction<AddIngredientsFeature.Action>)
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
                    return .run { [databaseClient, dismiss, meal = state.meal] _ in
                        try await databaseClient.insert(meal: meal)
                        await dismiss()
                    }

                case .addIngredientButtonTapped:
                    state.addIngredients = .init(ingredients: state.meal.ingredients)
                    return .none

                case .updateMeal(let meal):
                    state.meal = meal
                    return .none

                case .quantityPicker:
                    return .none

                case .onDeleteIngredients(let indices):
                    state.meal.ingredients.remove(atOffsets: indices)
                    return .none

                case .showAllIngredientsButtonTapped:
                    state.showsAllIngredients = true
                    return .none


                case .addIngredients(.dismiss):
                    guard let addIngredients = state.addIngredients else { return .none }
                    state.meal.ingredients = addIngredients.selectedIngredients
                    return .none

                case .addIngredients:
                    return .none
            }
        }
        .ifLet(\.$addIngredients, action: \.addIngredients) {
            AddIngredientsFeature()
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
