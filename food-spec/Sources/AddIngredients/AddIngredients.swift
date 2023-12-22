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

        var searchResults: IdentifiedArray<FoodID, IngredientPicker.State> {
            return ingredientPickers.filter {
                $0.ingredient.food.name.contains(foodSearch.query.lowercased())
            }
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
                case .foodSearch(.foodObservation(.updateFoods(let foods))):
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
