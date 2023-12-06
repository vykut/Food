//
//  FoodListReducerTests.swift
//  FoodSpecTests
//
//  Created by Victor Socaciu on 04/12/2023.
//

import XCTest
import ComposableArchitecture
import SwiftData
import GRDB
@testable import FoodSpec

@MainActor
final class FoodListReducerTests: XCTestCase {
    func testDefault() async throws {
        let store = TestStore(
            initialState: FoodListReducer.State(),
            reducer: {
                FoodListReducer()
            }
        )

        store.assert { state in
            state.recentFoodsSortingStrategy = .name
            state.recentFoodsSortingOrder = .forward
            state.searchQuery = ""
            state.isSearchFocused = false
            state.recentFoods = []
            state.searchResults = []
            state.shouldShowNoResults = false
            state.foodDetails = nil
        }
    }

    func test_onAppear() async throws {
        let store = TestStore(
            initialState: FoodListReducer.State(),
            reducer: {
                FoodListReducer()
            }
        )
        store.dependencies.databaseClient.getRecentFoods = { _, _ in
            []
        }
        let encoder = JSONEncoder()
        store.dependencies.userDefaults.override(data: try! encoder.encode(Food.SortingStrategy.energy), forKey: "recentSearchesSortingStrategyKey")
        store.dependencies.userDefaults.override(data: try! encoder.encode(SortOrder.reverse), forKey: "recentSearchesSortingOrderKey")

        await store.send(.onAppear)
        await store.receive(\.updateFromUserDefaults) {
            $0.recentFoodsSortingStrategy = .energy
            $0.recentFoodsSortingOrder = .reverse
        }
        await store.receive(\.didFetchRecentFoods) {
            $0.isSearchFocused = true
        }
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, false)
        XCTAssertNoDifference(store.state.shouldShowPrompt, true)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.shouldShowSearchResults, false)
    }

    func test_onAppear_hasRecentFoods() async throws {
        let food = Food.preview
        let store = TestStore(
            initialState: FoodListReducer.State(),
            reducer: {
                FoodListReducer()
            }
        )
        store.dependencies.databaseClient.getRecentFoods = { _, _ in
            [food]
        }
        let encoder = JSONEncoder()
        store.dependencies.userDefaults.override(data: try! encoder.encode(Food.SortingStrategy.energy), forKey: "recentSearchesSortingStrategyKey")
        store.dependencies.userDefaults.override(data: try! encoder.encode(SortOrder.reverse), forKey: "recentSearchesSortingOrderKey")

        await store.send(.onAppear)
        await store.receive(\.updateFromUserDefaults) {
            $0.recentFoodsSortingStrategy = .energy
            $0.recentFoodsSortingOrder = .reverse
        }
        await store.receive(\.didFetchRecentFoods) {
            $0.recentFoods = [.preview]
        }
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, true)
        XCTAssertNoDifference(store.state.shouldShowPrompt, false)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.shouldShowSearchResults, false)
    }

    func testFullFlow_newInstallation() async throws {
        let store = TestStore(
            initialState: FoodListReducer.State(),
            reducer: {
                FoodListReducer()
            },
            withDependencies: {
                $0.mainQueue = .immediate
            }
        )
        store.dependencies.databaseClient.getRecentFoods = { _, _ in
            []
        }
        let encoder = JSONEncoder()
        store.dependencies.userDefaults.override(data: try! encoder.encode(Food.SortingStrategy.energy), forKey: "recentSearchesSortingStrategyKey")
        store.dependencies.userDefaults.override(data: try! encoder.encode(SortOrder.reverse), forKey: "recentSearchesSortingOrderKey")

        await store.send(.onAppear)
        await store.receive(\.updateFromUserDefaults) {
            $0.recentFoodsSortingStrategy = .energy
            $0.recentFoodsSortingOrder = .reverse
        }
        await store.receive(\.didFetchRecentFoods) {
            $0.isSearchFocused = true
        }
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, false)
        XCTAssertNoDifference(store.state.shouldShowPrompt, true)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.shouldShowSearchResults, false)

        let foodApi = FoodApiModel.preview
        let food = Food(foodApiModel: foodApi)
        store.dependencies.foodClient.getFoods = { _ in [foodApi] }
        store.dependencies.databaseClient.insert = {
            XCTAssertNoDifference($0, .preview)
            return $0
        }
        store.dependencies.databaseClient.getRecentFoods = {
            XCTAssertEqual($0, .energy)
            XCTAssertEqual($1, .reverse)
            return [.preview]
        }
        await store.send(.updateSearchQuery("C")) {
            $0.searchQuery = "C"
            $0.shouldShowNoResults = false
            $0.searchResults = []
            $0.inlineFood = nil
        }
        await store.receive(\.startSearching) {
            $0.isSearching = true
        }
        XCTAssertEqual(store.state.shouldShowSpinner, true)
        await store.receive(\.didReceiveSearchFoods) {
            $0.inlineFood = .init(food: .preview)
            $0.isSearching = false
        }
        XCTAssertEqual(store.state.shouldShowSpinner, false)
    }
}
