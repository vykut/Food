import XCTest
import ComposableArchitecture
import Spotlight
import Shared
@testable import FoodList

@MainActor
final class SpotlightReducerTests: XCTestCase {
    func testIndexing() async throws {
        let eggplant = Food.eggplant
        let ribeye = Food.ribeye
        let foods = [eggplant, ribeye]
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                SpotlightReducer()
            }
        )
        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, foods)
        }
        await store.send(.onRecentFoodsChange(foods))
    }

    func testSpotlightSelection() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                SpotlightReducer()
            }
        )
        store.dependencies.databaseClient.getFood = {
            XCTAssertNoDifference($0, eggplant.name)
            return eggplant
        }
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchableItemActivityIdentifier] = eggplant.name
        await store.send(.spotlight(.handleSelectedFood(activity)))
        await store.receive(\.didSelectRecentFood)
    }

    func testSpotlightSearchInApp() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                SpotlightReducer()
            }
        )
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchQueryString] = eggplant.name
        await store.send(.spotlight(.handleSearchInApp(activity)))
        await store.receive(\.updateSearchFocus)
        await store.receive(\.updateSearchQuery)
    }

    func testSpotlightSearchInApp_foodDetailsAlreadyPresented() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: {
                var state = FoodListFeature.State()
                state.destination = .foodDetails(.init(food: eggplant))
                return state
            }(),
            reducer: {
                SpotlightReducer()
            }
        )
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchQueryString] = eggplant.name
        await store.send(.spotlight(.handleSearchInApp(activity)))
        await store.receive(\.destination.dismiss)
        await store.receive(\.updateSearchFocus)
        await store.receive(\.updateSearchQuery)
    }
}
