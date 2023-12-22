import Foundation
import ComposableArchitecture
import Spotlight
import Database

// TODO: Move to AppReducer

@Reducer
struct SpotlightReducer {
    typealias State = FoodList.State
    typealias Action = FoodList.Action

    @Dependency(\.spotlightClient) var spotlightClient
    @Dependency(\.databaseClient) var databaseClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .spotlight(.handleSelectedFood(let activity)):
                    guard let foodName = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return .none }
                    return .run { send in
                        guard let food = try await databaseClient.getFood(name: foodName) else { return }
                        await send(.didSelectRecentFood(food))
                    }

                case .spotlight(.handleSelectedFood(let activity)):
                    guard let searchString = activity.userInfo?[CSSearchQueryString] as? String else { return .none }
                    return .run { [destination = state.destination, isSearchFocused = state.searchableFoodList.foodSearch.isFocused] send in
                        if destination != nil {
                            await send(.destination(.dismiss))
                        }
//                        if !isSearchFocused {
//                            await send(.foodSearch(.updateFocus(true)))
//                        }
                        await send(.searchableFoodList(.foodSearch(.updateQuery(searchString))))
                    }

                default:
                    return .none
            }
        }
        .onChange(of: \.searchableFoodList.foodObservation.foods) { _, newFoods in
            Reduce { _, _ in
                return .run { _ in
                    try await spotlightClient.indexFoods(foods: newFoods)
                } catch: { _, error in
                    dump(error)
                }
            }
        }
    }
}

extension FoodList.Action {
    @CasePathable
    public enum Spotlight {
        case handleSelectedFood(NSUserActivity)
        case handleSearchInApp(NSUserActivity)
    }
}
