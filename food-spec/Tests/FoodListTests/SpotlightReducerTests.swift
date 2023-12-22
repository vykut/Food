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
            initialState: FoodList.State(),
            reducer: {
                SpotlightReducer()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.spotlightClient.indexFoods = {
                    XCTAssertNoDifference($0, foods)
                }
            }
        )
        await store.send(.foodSearch(.foodObservation(.updateFoods(foods))))
    }

    func testSpotlightSelection() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                SpotlightReducer()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.databaseClient.getFood = {
                    XCTAssertNoDifference($0, eggplant.name)
                    return eggplant
                }
            }
        )
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchableItemActivityIdentifier] = eggplant.name
        await store.send(.spotlight(.handleSelectedFood(activity)))
        await store.receive(\.didSelectRecentFood)
    }

    func testSpotlightSearchInApp() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                SpotlightReducer()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchQueryString] = eggplant.name
        await store.send(.spotlight(.handleSearchInApp(activity)))
        await store.receive(\.foodSearch.updateFocus)
        await store.receive(\.foodSearch.updateQuery)
    }

    func testSpotlightSearchInApp_foodDetailsAlreadyPresented() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: {
                var state = FoodList.State()
                state.destination = .foodDetails(.init(food: eggplant))
                return state
            }(),
            reducer: {
                SpotlightReducer()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchQueryString] = eggplant.name
        await store.send(.spotlight(.handleSearchInApp(activity)))
        await store.receive(\.destination.dismiss)
        await store.receive(\.foodSearch.updateFocus)
        await store.receive(\.foodSearch.updateQuery)
    }
}
