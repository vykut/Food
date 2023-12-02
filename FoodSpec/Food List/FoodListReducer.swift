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
        var recentFoods: [Food] = []
        var searchQuery = ""
        var isSearchFocused = false
        var isSearching = false
        var searchResults: [FoodApiModel] = []
        var shouldShowNoResults: Bool = false
        var searchTask: Task<Void, Error>?
        var inlineFood: FoodDetailsReducer.State?
        @PresentationState var foodDetails: FoodDetailsReducer.State?

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
            isSearchFocused && !searchResults.isEmpty && inlineFood == nil
        }
    }
    @CasePathable
    enum Action {
        case onAppear
        case updateSearchQuery(String)
        case updateSearchFocus(Bool)
        case didSelectRecentFood(Food)
        case didSelectSearchResult(FoodApiModel)
        case didDeleteRecentFoods(IndexSet)
        case startSearching
        case didReceiveSearchFoods([FoodApiModel])
        case foodDetails(PresentationAction<FoodDetailsReducer.Action>)
        case inlineFood(FoodDetailsReducer.Action)
    }

    enum CancelID {
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

                case .updateSearchQuery(let query):
                    guard state.searchQuery != query else { return .none }
                    state.searchQuery = query
                    state.shouldShowNoResults = false
                    state.searchResults = []
                    state.inlineFood = nil
                    if query.isEmpty {
                        state.isSearching = false
                        return .cancel(id: CancelID.search)
                    } else {
                        return .run { [searchQuery = state.searchQuery] send in
                            await send(.startSearching)
                            let foods = try await foodClient.getFoods(query: searchQuery)
                            await send(.didReceiveSearchFoods(foods))
                        } catch: { error, send in
                            dump(error)
                        }
                        .debounce(id: CancelID.search, for: .milliseconds(300), scheduler: mainQueue)
                    }

                case .startSearching:
                    state.isSearching = true
                    return .none

                case .didReceiveSearchFoods(let foods):
                    state.isSearching = false
                    if foods.isEmpty {
                        state.shouldShowNoResults = true
                    } else if foods.count == 1 {
                        let food = Food(foodApiModel: foods[0], date: .now)
                        state.recentFoods.insert(food, at: 0)
                        state.inlineFood = .init(food: food)
                    } else {
                        state.searchResults = foods
                    }
                    return .none

                case .updateSearchFocus(let focus):
                    guard state.isSearchFocused != focus else { return .none }
                    state.isSearchFocused = focus
                    if !focus {
                        state.inlineFood = nil
                    }
                    return .none

                case .didSelectRecentFood(let food):
                    state.foodDetails = .init(food: food)
                    return .none

                case .didSelectSearchResult(let food):
                    let food = Food(foodApiModel: food, date: now)
                    if !state.recentFoods.contains(where: { $0.name == food.name }) {
                        state.recentFoods.insert(food, at: 0)
                    }
                    state.foodDetails = .init(food: food)
                    return .none

                case .didDeleteRecentFoods(let indices):
                    state.recentFoods.remove(atOffsets: indices)
                    return .none

                case .foodDetails(let foodDetails):
                    return .none

                case .inlineFood(let foodDetails):
                    return .none
            }
        }
    }
}
