import Foundation
import Shared
import IngredientPicker
import Database
import SearchableFoodList
import ComposableArchitecture

@Reducer
public struct AddIngredients {
    public typealias FoodID = Int64?

    @ObservableState
    public struct State: Hashable {
        var initialIngredients: [Ingredient]
        var ingredientPickers: IdentifiedArray<FoodID, IngredientPicker.State> = .init(id: \.food.id)
        var searchableFoodList: SearchableFoodList.State = .init()

        public var selectedIngredients: [Ingredient] {
            ingredientPickers
                .filter(\.isSelected)
                .map(\.ingredient)
        }

        var searchResults: IdentifiedArray<FoodID, IngredientPicker.State> {
            ingredientPickers.filter { picker in
                searchableFoodList.searchResults.contains(where: { $0.id == picker.food.id })
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
        case searchableFoodList(SearchableFoodList.Action)
        case doneButtonTapped
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.dismiss) private var dismiss

    public var body: some ReducerOf<Self> {
        Scope(state: \.searchableFoodList, action: \.searchableFoodList) {
            SearchableFoodList()
        }
        Reduce { state, action in
            switch action {
                case .searchableFoodList:
                    return .none

                case .ingredientPickers:
                    return .none

                case .doneButtonTapped:
                    return .run { _ in
                        await dismiss()
                    }
            }
        }
        .onChange(of: \.searchableFoodList.foodObservation.foods) { _, newFoods in
            Reduce { state, _ in
                for food in newFoods {
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
            }
        }
        .forEach(\.ingredientPickers, action: \.ingredientPickers) {
            IngredientPicker()
        }
    }
}
