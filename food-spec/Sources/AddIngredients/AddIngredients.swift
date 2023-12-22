import Foundation
import Shared
import IngredientPicker
import Database
import Search
import ComposableArchitecture

@Reducer
public struct AddIngredients {
    public typealias FoodID = Int64?

    @ObservableState
    public struct State: Hashable {
        var initialIngredients: [Ingredient]
        var ingredientPickers: IdentifiedArray<FoodID, IngredientPicker.State> = .init(id: \.food.id)
        var foodSearch: FoodSearch.State = .init()

        public var selectedIngredients: [Ingredient] {
            ingredientPickers
                .filter(\.isSelected)
                .map(\.ingredient)
        }

        public init(ingredients: [Ingredient] = []) {
            self.initialIngredients = ingredients
            for ingredient in ingredients {
                ingredientPickers.append(.init(
                    food: ingredient.food,
                    quantity: ingredient.quantity
                ))
            }
        }
    }

    @CasePathable
    public enum Action {
        case onFirstAppear
        case updateFoods([Food])
        case ingredientPickers(IdentifiedAction<FoodID, IngredientPicker.Action>)
        case foodSearch(FoodSearch.Action)
        case doneButtonTapped
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.dismiss) private var dismiss

    public var body: some ReducerOf<Self> {
        Scope(state: \.foodSearch, action: \.foodSearch) {
            FoodSearch()
        }
        Reduce { state, action in
            switch action {
                case .onFirstAppear:
                    return .run { [databaseClient] send in
                        let foods = try await databaseClient.getRecentFoods(sortedBy: Column("name"), order: .forward)
                        await send(.updateFoods(foods))
                    }

                    // todo: when reducer is initialized with nonempty ingredients, put them at the top of the list, if any is deselected, move it in the list (sort it)
                    // don't move pickers up and down based on selection as it can be bad UX to the user

                case .updateFoods(let foods):
                    for food in foods {
                        if let alreadySelectedIngredient = state.initialIngredients.first(where: { $0.food.id == food.id }) {
                            let ingredientPicker = IngredientPicker.State(
                                food: food,
                                quantity: alreadySelectedIngredient.quantity
                            )
                            state.ingredientPickers.updateOrAppend(ingredientPicker)
                        } else {
                            state.ingredientPickers.updateOrAppend(.init(food: food))
                        }
                    }
                    return .none

                case .ingredientPickers:
                    return .none

                case .foodSearch:
                    return .none

                case .doneButtonTapped:
                    return .run { _ in
                        await dismiss()
                    }
            }
        }
        .forEach(\.ingredientPickers, action: \.ingredientPickers) {
            IngredientPicker()
        }
    }
}
