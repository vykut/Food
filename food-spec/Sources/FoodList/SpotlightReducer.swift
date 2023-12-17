import Foundation
import ComposableArchitecture
import Spotlight
import Database

@Reducer
struct SpotlightReducer {
    typealias State = FoodListFeature.State
    typealias Action = FoodListFeature.Action

    @Dependency(\.spotlightClient) var spotlightClient
    @Dependency(\.databaseClient) var databaseClient

    func reduce(into state: inout FoodListFeature.State, action: FoodListFeature.Action) -> Effect<FoodListFeature.Action> {
        switch action {
            case .onRecentFoodsChange(let recentFoods):
                return .run { send in
                    do {
                        try await spotlightClient.indexFoods(foods: recentFoods)
                    } catch {
                        dump(error)
                    }
                }
            case .spotlight(let spotlight):
                return reduce(into: &state, action: spotlight)

            default:
                return .none
        }
    }

    private func reduce(into state: inout FoodListFeature.State, action: FoodListFeature.Action.Spotlight) -> Effect<FoodListFeature.Action> {
        switch action {
            case .handleSelectedFood(let activity):
                guard let foodName = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return .none }
                return .run { send in
                    guard let food = try await databaseClient.getFood(name: foodName) else { return }
                    await send(.didSelectRecentFood(food))
                }

            case .handleSearchInApp(let activity):
                guard let searchString = activity.userInfo?[CSSearchQueryString] as? String else { return .none }
                return .run { [destination = state.destination, isSearchFocused = state.isSearchFocused] send in
                    if destination != nil {
                        await send(.destination(.dismiss))
                    }
                    if !isSearchFocused {
                        await send(.updateSearchFocus(true))
                    }
                    await send(.updateSearchQuery(searchString))
                }
        }
    }
}

extension FoodListFeature.Action {
    @CasePathable
    public enum Spotlight {
        case handleSelectedFood(NSUserActivity)
        case handleSearchInApp(NSUserActivity)
    }
}
