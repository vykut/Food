//
//  FoodListReducer.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 02/12/2023.
//

import Foundation
import GRDB
import ComposableArchitecture

@Reducer
struct FoodListReducer {
    @ObservableState
    struct State: Hashable {
        var recentFoods: [Food] = []
        var recentFoodsSortingStrategy: Food.SortingStrategy = .name
        var recentFoodsSortingOrder: SortOrder = .forward
        var searchQuery = ""
        var isSearchFocused = false
        var isSearching = false
        var searchResults: [Food] = []
        var shouldShowNoResults: Bool = false
        var inlineFood: FoodDetailsReducer.State?
        @Presents var foodDetails: FoodDetailsReducer.State?

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
        case updateFromUserDefaults(Food.SortingStrategy?, SortOrder?)
        case fetchRecentFoods
        case didFetchRecentFoods([Food])
        case updateSearchQuery(String)
        case updateSearchFocus(Bool)
        case didSelectRecentFood(Food)
        case didSelectSearchResult(Food)
        case didDeleteRecentFoods(IndexSet)
        case startSearching
        case didReceiveSearchFoods([FoodApiModel])
        case foodDetails(PresentationAction<FoodDetailsReducer.Action>)
        case inlineFood(FoodDetailsReducer.Action)
        case updateRecentFoodsSortingStrategy(Food.SortingStrategy)
    }

    enum CancelID {
        case search
    }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.foodClient) private var foodClient
    @Dependency(\.mainQueue) private var mainQueue
    @Dependency(\.userDefaults) private var userDefaults

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    return .run { send in
                        let strategy = userDefaults.recentSearchesSortingStrategy
                        let order = userDefaults.recentSearchesSortingOrder
                        await send(.updateFromUserDefaults(strategy, order))
                        await send(.fetchRecentFoods)
                    }

                case .updateFromUserDefaults(let strategy, let order):
                    if let strategy {
                        state.recentFoodsSortingStrategy = strategy
                    }
                    if let order {
                        state.recentFoodsSortingOrder = order
                    }
                    return .none

                case .fetchRecentFoods:
                    return .run { [sortingStrategy = state.recentFoodsSortingStrategy, order = state.recentFoodsSortingOrder] send in
                        let recentFoods = try await databaseClient.getRecentFoods(sortedBy: sortingStrategy, order: order)
                        await send(.didFetchRecentFoods(recentFoods))
                    }

                case .didFetchRecentFoods(let foods):
                    state.recentFoods = foods
                    if foods.isEmpty && state.searchQuery.isEmpty {
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
                            await send(.didReceiveSearchFoods([]))
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
                        let food = Food(foodApiModel: foods[0])
                        state.inlineFood = .init(food: food)
                        return .run { send in
                            try await databaseClient.insert(food: food)
                            await send(.fetchRecentFoods)
                        }
                    } else {
                        state.searchResults = foods.map { .init(foodApiModel: $0) }
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
                    state.foodDetails = .init(food: food)
                    return .run { send in
                        _ = try await databaseClient.insert(food: food)
                        await send(.fetchRecentFoods)
                    }

                case .didDeleteRecentFoods(let indices):
                    return .run { [recentFoods = state.recentFoods] send in
                        let foodsToDelete = indices.map { recentFoods[$0] }
                        for food in foodsToDelete {
                            try await databaseClient.delete(food: food)
                        }
                        await send(.fetchRecentFoods)
                    }

                case .foodDetails(let foodDetails):
                    return .none

                case .inlineFood(let foodDetails):
                    return .none

                case .updateRecentFoodsSortingStrategy(let newStrategy):
                    if newStrategy == state.recentFoodsSortingStrategy {
                        state.recentFoodsSortingOrder.toggle()
                    } else {
                        state.recentFoodsSortingStrategy = newStrategy
                        state.recentFoodsSortingOrder = .forward
                    }
                    return .run { [strategy = state.recentFoodsSortingStrategy, order = state.recentFoodsSortingOrder] send in
                        userDefaults.recentSearchesSortingStrategy = strategy
                        userDefaults.recentSearchesSortingOrder = order
                        await send(.fetchRecentFoods)
                    }
            }
        }
        .ifLet(\.$foodDetails, action: \.foodDetails) {
            FoodDetailsReducer()
        }
    }
}

extension SortOrder {
    mutating func toggle() {
        self = switch self {
            case .forward: .reverse
            case .reverse: .forward
        }
    }
}
