import Foundation
import Shared
import IngredientPicker
import Database
import Search
import DatabaseObservation
import ComposableArchitecture

@Reducer
public struct AddIngredients: Sendable {
    public typealias IngredientPickers = IdentifiedArray<FoodID, IngredientPicker.State>
    public typealias FoodID = Int64?

    @ObservableState
    public struct State: Hashable {
        var initialIngredients: [Ingredient]
        var ingredientPickers: IngredientPickers = .init(id: \.food.id)
        var foodSearch: FoodSearch.State = .init()
        var foodObservation: FoodObservation.State = .init()

        public var selectedIngredients: [Ingredient] {
            ingredientPickers
                .filter(\.isSelected)
                .map(\.ingredient)
        }

        var searchResults: IngredientPickers {
            let results = Set(foodSearch.searchResults.map(\.id))
            return ingredientPickers.filter { picker in
                results.contains(picker.food.id)
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
        case foodObservation(FoodObservation.Action)
        case doneButtonTapped
    }

    public init() { }

    @Dependency(\.dismiss) private var dismiss

    public var body: some ReducerOf<Self> {
        Scope(state: \.foodObservation, action: \.foodObservation) {
            FoodObservation()
        }
        Scope(state: \.foodSearch, action: \.foodSearch) {
            FoodSearch()
        }
        Reduce { state, action in
            switch action {
                case .foodObservation(.updateFoods(let newFoods)):
                    var pickers: IngredientPickers = .init(id: \.food.id)
                    for food in newFoods {
                        if let picker = state.ingredientPickers[id: food.id] {
                            pickers.append(picker)
                        } else {
                            pickers.append(.init(food: food))
                        }
                    }
                    state.ingredientPickers = pickers
                    return .none

                case .foodObservation:
                    return .none

                case .foodSearch:
                    return .none

                case .ingredientPickers:
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
