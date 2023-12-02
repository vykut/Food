//
//  FoodListReducer.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 02/12/2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FoodListReducer {
    @ObservableState
    struct State {
        var navigationStack: [FoodDetailsReducer.State] = []
        var recentFoods: [Food] = []
        var searchQuery = ""
        var isSearchFocused = false
        var isSearching = false
        var searchResults: [FoodApiModel] = []
        var shouldShowNoResults: Bool = false
        var searchTask: Task<Void, Error>?

        var shouldShowRecentSearches: Bool {
            searchQuery.isEmpty && !recentFoods.isEmpty
        }

        var shouldShowPrompt: Bool {
            searchQuery.isEmpty && recentFoods.isEmpty && !shouldShowNoResults
        }

        var shouldShowSpinner: Bool {
            isSearching
        }

        var shouldShowSearchResults: Bool {
            isSearchFocused && !searchResults.isEmpty
        }
    }
    @CasePathable
    enum Action {
        case onAppear
        case updateSearchQuery(String)
        case updateSearchFocus(Bool)
        case updateNavigationStack([FoodDetailsReducer.State])
        case didSelectRecentFood(Food)
        case didSelectSearchResult(FoodApiModel)
        case didDeleteRecentFoods(IndexSet)
        case didReceiveSearchResult(Result<[FoodApiModel], Error>)
    }

    enum ID {
        case search
    }

    @Dependency(\.foodClient) private var foodClient
    @Dependency(\.mainQueue) private var mainQueue
    @Dependency(\.date.now) private var now

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    if state.recentFoods.isEmpty && state.searchQuery.isEmpty {
                        state.isSearchFocused = true
                    }
                    return .none

                case .updateNavigationStack(let navigationStack):
                    state.navigationStack = navigationStack
                    return .none

                case .updateSearchQuery(let query):
                    state.searchQuery = query
                    state.shouldShowNoResults = false
                    state.searchResults = []
                    if query.isEmpty {
                        return .cancel(id: ID.search)
                    } else {
                        state.isSearching = true
                        return .run { [searchQuery = state.searchQuery] send in
                            let result = await Result {
                                try await foodClient.getFoods(query: searchQuery)
                            }

                            await send(.didReceiveSearchResult(result))
                        }
                        .debounce(id: ID.search, for: .milliseconds(300), scheduler: mainQueue)
                    }

                case .didReceiveSearchResult(let result):
                    state.isSearching = false
                    switch result {
                        case .success(let foods):
                            if foods.isEmpty {
                                state.shouldShowNoResults = true
                            } else {
                                state.searchResults = foods
                            }
                        case .failure(let error):
                            print(error) // handle errors
                    }
                    return .none

                case .updateSearchFocus(let focus):
                    state.isSearchFocused = focus
                    return .none

                case .didSelectRecentFood(let food):
                    state.navigationStack.append(.init(food: food))
                    return .none

                case .didSelectSearchResult(let food):
                    let food = Food(foodApiModel: food, date: now)
                    if !state.recentFoods.contains(where: { $0.name == food.name }) {
                        state.recentFoods.insert(food, at: 0)
                    }
                    state.navigationStack.append(.init(food: food))
                    return .none

                case .didDeleteRecentFoods(let indices):
                    state.recentFoods.remove(atOffsets: indices)
                    return .none
            }
        }
    }
}
