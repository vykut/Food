import Foundation
import Shared
import Database
import AddIngredients
import ComposableArchitecture

@Reducer
public struct MealFormFeature {
    @ObservableState
    public struct State: Hashable {
        public var meal: Meal
        var showsAllIngredients: Bool = false
        var isEdit: Bool
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
            self.isEdit = false
        }

        public init(meal: Meal) {
            self.meal = meal
            self.isEdit = true
        }
    }

    @CasePathable
    public enum Action {
        case cancelButtonTapped
        case saveButtonTapped
        case addIngredientsButtonTapped
        case updateMeal(Meal)
        case servingsIncrementButtonTapped
        case servingsDecrementButtonTapped
        case ingredientTapped(Ingredient)
        case onDeleteIngredients(IndexSet)
        case showAllIngredientsButtonTapped
        case addIngredients(PresentationAction<AddIngredientsFeature.Action>)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate {
            case mealSaved(Meal)
        }
    }

    public init() { }

    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .cancelButtonTapped:
                    return .run { [dismiss] _ in
                        await dismiss()
                    }

                case .saveButtonTapped:
                    return .run { [databaseClient, dismiss, meal = state.meal] send in
                        try await databaseClient.insert(meal: meal)
                        await send(.delegate(.mealSaved(meal)))
                        await dismiss()
                    }

                case .addIngredientsButtonTapped:
                    state.addIngredients = .init(ingredients: state.meal.ingredients)
                    return .none

                case .ingredientTapped(let ingredient):
                    state.addIngredients = .init(ingredients: state.meal.ingredients)
                    return .none

                case .updateMeal(let meal):
                    state.meal = meal
                    return .none

                case .servingsIncrementButtonTapped:
                    state.meal.servings += 0.5
                    return .none

                case .servingsDecrementButtonTapped:
                    guard state.meal.servings > 0.5 else { return .none }
                    state.meal.servings -= 0.5
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

                case .delegate:
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
            servings: 1,
            instructions: ""
        )
    }
}
