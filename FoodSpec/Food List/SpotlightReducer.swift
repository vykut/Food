//
//  SpotlightReducer.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 07/12/2023.
//

import Foundation
import ComposableArchitecture
import CoreSpotlight

@Reducer
struct SpotlightReducer {
    typealias State = FoodListReducer.State
    typealias Action = FoodListReducer.Action

    @Dependency(\.spotlightClient) var spotlightClient
    @Dependency(\.databaseClient) var databaseClient

    func reduce(into state: inout FoodListReducer.State, action: FoodListReducer.Action) -> Effect<FoodListReducer.Action> {
        switch action {
            case .didFetchRecentFoods(let recentFoods):
                return .run { send in
                    do {
                        try await spotlightClient.indexFoods(foods: recentFoods)
                    } catch {
                        dump(error)
                    }
                }
            case .spotlight(.handleSelectedFood(let activity)):
                guard let foodName = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return .none }
                return .run { send in
                    guard let food = try await databaseClient.getFood(name: foodName) else { return }
                    await send(.didSelectRecentFood(food))
                }

            case .spotlight(.handleSearchInApp(let activity)):
                guard let searchString = activity.userInfo?[CSSearchQueryString] as? String else { return .none }
                return .run { [foodDetails = state.foodDetails, isSearchFocused = state.isSearchFocused] send in
                    if foodDetails != nil {
                        await send(.foodDetails(.dismiss))
                    }
                    if !isSearchFocused {
                        await send(.updateSearchFocus(true))
                    }
                    await send(.updateSearchQuery(searchString))
                }

            default:
                return .none
        }
    }
}

extension FoodListReducer.Action {
    @CasePathable
    enum Spotlight {
        case handleSelectedFood(NSUserActivity)
        case handleSearchInApp(NSUserActivity)
    }
}
