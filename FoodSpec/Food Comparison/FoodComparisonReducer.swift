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
        var searchQuery: String = ""
        var isShowingComparison: Bool = false

        var filteredFoods: [Food] {
            guard !searchQuery.isEmpty else { return foods }
            return foods.filter {
                $0.name.range(of: searchQuery, options: .caseInsensitive) != nil
            }
        }

        var isCompareButtonDisabled: Bool {
            selectedFoodIds.count < 2
        }
    }

    @CasePathable
    enum Action {
        case didTapCancel
        case didTapCompare
        case didChangeSelection(Set<Int64?>)
        case didNavigateToComparison(Bool)
        case updateSearchQuery(String)
    }

    @Dependency(\.dismiss) private var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .didChangeSelection(let selection):
                    state.selectedFoodIds = selection
                    return .none

                case .didTapCompare:
                    state.isShowingComparison = true
                    return .none

                case .updateSearchQuery(let query):
                    state.searchQuery = query
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
