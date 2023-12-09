//
//  FoodComparisonReducer.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 09/12/2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FoodComparisonReducer {
    @ObservableState
    struct State: Hashable {
        var foods: [Food] = []
        var selectedFoodIds: Set<Int64?> = []
        var comparedFoods: [Food] = []
        var searchQuery: String = ""
        var isShowingComparison: Bool = false
        var comparison: Comparison = .energy
        var foodSortingStrategy: SortingStrategy = .value
        var foodSortingOrder: SortOrder = .forward

        var filteredFoods: [Food] {
            guard !searchQuery.isEmpty else { return foods }
            return foods.filter {
                $0.name.range(of: searchQuery, options: .caseInsensitive) != nil
            }
        }

        var isCompareButtonDisabled: Bool {
            selectedFoodIds.count < 2
        }

        func isSelectionDisabled(for food: Food) -> Bool {
            selectedFoodIds.count >= 7 &&
            !selectedFoodIds.contains(food.id)
        }

        enum Comparison: String, Identifiable, Hashable, CaseIterable {
            case energy
            case protein
            case carbohydrates
            case fat
            case potassium
            case sodium
            case macronutrients

            var id: Self { self }
        }

        enum SortingStrategy: String, Identifiable, Hashable {
            case name
            case value
            case protein
            case carbohydrates
            case fat

            var id: Self { self }
        }
    }

    @CasePathable
    enum Action {
        case didTapCancel
        case didTapCompare
        case didChangeSelection(Set<Int64?>)
        case didNavigateToComparison(Bool)
        case updateSearchQuery(String)
        case updateSortingStrategy(State.SortingStrategy)
        case updateComparisonType(State.Comparison)
    }

    @Dependency(\.dismiss) private var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .didChangeSelection(let selection):
                    state.selectedFoodIds = selection
                    return .none

                case .didTapCompare:
                    state.comparedFoods = state.filteredFoods
                        .lazy
                        .filter { [selectedIds = state.selectedFoodIds] food in
                            selectedIds.contains(food.id)
                        }
                        .sorted(using: SortDescriptor(\.energy, order: .forward))
                    state.isShowingComparison = true
                    return .none

                case .updateSearchQuery(let query):
                    state.searchQuery = query
                    return .none

                case .updateSortingStrategy(let strategy):
                    if state.foodSortingStrategy == strategy {
                        state.foodSortingOrder.toggle()
                    } else {
                        state.foodSortingStrategy = strategy
                        state.foodSortingOrder = .forward
                    }
                    return .none

                case .updateComparisonType(let comparison):
                    state.comparison = comparison
                    return .none

                case .didTapCancel:
                    return .run { _ in
                        await dismiss()
                    }

                case .didNavigateToComparison(let bool):
                    guard bool != state.isShowingComparison else { return .none }
                    state.isShowingComparison = bool
                    return .none
            }
        }
    }
}
