//
//  SpotlightReducerTests.swift
//  FoodSpecTests
//
//  Created by Victor Socaciu on 08/12/2023.
//

import XCTest
import ComposableArchitecture
import CoreSpotlight
@testable import FoodSpec

@MainActor
final class SpotlightReducerTests: XCTestCase {
    func testIndexing() async throws {
        let eggplant = Food.eggplant
        let ribeye = Food.ribeye
        let foods = [eggplant, ribeye]
        let store = TestStore(
            initialState: FoodListReducer.State(),
            reducer: {
                SpotlightReducer()
            }
        )
        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, foods)
        }
        await store.send(.didFetchRecentFoods(foods))
    }

    func testSpotlightSelection() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: FoodListReducer.State(),
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
            initialState: FoodListReducer.State(),
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
            initialState: FoodListReducer.State(
                foodDetails: .init(food: eggplant)
            ),
            reducer: {
                SpotlightReducer()
            }
        )
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchQueryString] = eggplant.name
        await store.send(.spotlight(.handleSearchInApp(activity)))
        await store.receive(\.foodDetails.dismiss)
        await store.receive(\.updateSearchFocus)
        await store.receive(\.updateSearchQuery)
    }
}
