import XCTest
import ComposableArchitecture
import Shared
import API
import Spotlight
@testable import Billboard
@testable import FoodList

@MainActor
final class FoodListTests: XCTestCase {
    func testStateDefaultInitializer() async throws {
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
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
            state.billboard = .init(banner: nil)
            state.foodComparison = nil
            state.alert = nil
        }
    }

    func test_onAppear() async throws {
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
            }
        )
        let (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [])
        }
        store.dependencies.billboardClient.getRandomBanners = {
            .finished()
        }
        store.dependencies.databaseClient.observeFoods = { sortedBy, order in
            XCTAssertEqual(sortedBy, .energy)
            XCTAssertEqual(order, .reverse)
            return stream
        }
        let encoder = JSONEncoder()
        store.dependencies.userDefaults.override(data: try! encoder.encode(Food.SortingStrategy.energy), forKey: "recentSearchesSortingStrategyKey")
        store.dependencies.userDefaults.override(data: try! encoder.encode(SortOrder.reverse), forKey: "recentSearchesSortingOrderKey")

        await store.send(.onAppear)
        await store.receive(\.updateFromUserDefaults) {
            $0.recentFoodsSortingStrategy = .energy
            $0.recentFoodsSortingOrder = .reverse
        }
        await store.receive(\.startObservingRecentFoods)
        continuation.yield([])
        await store.receive(\.didFetchRecentFoods) {
            $0.isSearchFocused = true
        }
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, false)
        XCTAssertNoDifference(store.state.shouldShowPrompt, true)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.shouldShowSearchResults, false)
        continuation.finish()
        await store.finish()
    }

    func test_onAppear_hasRecentFoods() async throws {
        let food = Food.preview
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
            }
        )
        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [food])
        }
        store.dependencies.billboardClient.getRandomBanners = {
            .finished()
        }
        let (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = { sortedBy, order in
            XCTAssertEqual(sortedBy, .energy)
            XCTAssertEqual(order, .reverse)
            return stream
        }
        let encoder = JSONEncoder()
        store.dependencies.userDefaults.override(data: try! encoder.encode(Food.SortingStrategy.energy), forKey: "recentSearchesSortingStrategyKey")
        store.dependencies.userDefaults.override(data: try! encoder.encode(SortOrder.reverse), forKey: "recentSearchesSortingOrderKey")

        await store.send(.onAppear)
        await store.receive(\.updateFromUserDefaults) {
            $0.recentFoodsSortingStrategy = .energy
            $0.recentFoodsSortingOrder = .reverse
        }
        await store.receive(\.startObservingRecentFoods)
        continuation.yield([food])
        await store.receive(\.didFetchRecentFoods) {
            $0.recentFoods = [food]
        }

        XCTAssertNoDifference(store.state.isSearchFocused, false)
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, true)
        XCTAssertNoDifference(store.state.shouldShowPrompt, false)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.shouldShowSearchResults, false)

        continuation.finish()
        await store.finish()
    }

    func testFullFlow_newInstallation() async throws {
        let eggplantApi = FoodApiModel.eggplant
        let eggplant = Food(foodApiModel: eggplantApi)
        let ribeyeApi = FoodApiModel.ribeye
        let ribeye = Food(foodApiModel: ribeyeApi)
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
            },
            withDependencies: {
                $0.mainQueue = .immediate
            }
        )
        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [])
        }
        store.dependencies.billboardClient.getRandomBanners = {
            .init {
                $0.yield(.preview)
                $0.finish()
            }
        }
        var (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = { sortedBy, order in
            XCTAssertEqual(sortedBy, .energy)
            XCTAssertEqual(order, .reverse)
            return stream
        }
        let encoder = JSONEncoder()
        store.dependencies.userDefaults.override(data: try! encoder.encode(Food.SortingStrategy.energy), forKey: "recentSearchesSortingStrategyKey")
        store.dependencies.userDefaults.override(data: try! encoder.encode(SortOrder.reverse), forKey: "recentSearchesSortingOrderKey")

        await store.send(.onAppear)
        await store.receive(\.updateFromUserDefaults) {
            $0.recentFoodsSortingStrategy = .energy
            $0.recentFoodsSortingOrder = .reverse
        }
        await store.receive(\.startObservingRecentFoods)
        await store.receive(\.billboard.showBanner) {
            $0.billboard.banner = .preview
        }
        continuation.yield([])
        await store.receive(\.didFetchRecentFoods) {
            $0.isSearchFocused = true
        }
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, true)
        XCTAssertNoDifference(store.state.isSortMenuDisabled, true)
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, false)
        XCTAssertNoDifference(store.state.shouldShowPrompt, true)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.shouldShowSearchResults, false)

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [eggplant])
        }
        store.dependencies.foodClient.getFoods = { _ in [eggplantApi] }
        store.dependencies.databaseClient.insert = {
            XCTAssertNoDifference($0, .preview)
            return $0
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
        continuation.yield([eggplant])
        await store.receive(\.didFetchRecentFoods) {
            $0.recentFoods = [eggplant]
        }
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, true)
        XCTAssertNoDifference(store.state.isSortMenuDisabled, true)

        await store.send(.updateSearchQuery("")) {
            $0.searchQuery = ""
            $0.shouldShowNoResults = false
            $0.searchResults = []
            $0.inlineFood = nil
            $0.isSearching = false
        }
        store.exhaustivity = .off(showSkippedAssertions: true)
        store.dependencies.foodClient.getFoods = { _ in [] }
        await store.send(.updateSearchQuery("R"))
        await store.send(.updateSearchQuery("Ri"))
        await store.send(.updateSearchQuery("Rib"))
        await store.send(.updateSearchQuery("Ribe"))
        await store.send(.updateSearchQuery("Ribey"))
        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [ribeye, eggplant])
        }
        store.dependencies.foodClient.getFoods = { _ in [ribeyeApi] }
        store.dependencies.databaseClient.insert = {
            XCTAssertEqual($0, ribeye)
            return $0
        }
        await store.send(.updateSearchQuery("Ribeye")) {
            $0.searchQuery = "Ribeye"
            $0.shouldShowNoResults = false
        }
        store.exhaustivity = .on
        await store.receive(\.startSearching) {
            $0.isSearching = true
        }
        await store.receive(\.didReceiveSearchFoods) {
            $0.isSearching = false
            $0.inlineFood = .init(food: ribeye)
        }
        await store.send(.didFetchRecentFoods([ribeye, eggplant])) {
            $0.recentFoods = [ribeye, eggplant]
        }
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, false)
        XCTAssertNoDifference(store.state.isSortMenuDisabled, false)

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [eggplant, ribeye])
        }
        store.dependencies.userDefaults.set = { _, _ in }
        (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = { sortedBy, order in
            XCTAssertEqual(sortedBy, .carbohydrates)
            XCTAssertEqual(order, .forward)
            return stream
        }
        await store.send(.updateRecentFoodsSortingStrategy(.carbohydrates)) {
            $0.recentFoodsSortingStrategy = .carbohydrates
            $0.recentFoodsSortingOrder = .forward
        }
        await store.receive(\.startObservingRecentFoods)
        continuation.yield([eggplant, ribeye])
        await store.receive(\.didFetchRecentFoods) {
            $0.recentFoods = [eggplant, ribeye]
        }
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, false)
        XCTAssertNoDifference(store.state.isSortMenuDisabled, false)

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [ribeye, eggplant])
        }
        (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = { sortedBy, order in
            XCTAssertEqual(sortedBy, .carbohydrates)
            XCTAssertEqual(order, .reverse)
            return stream
        }
        await store.send(.updateRecentFoodsSortingStrategy(.carbohydrates)) {
            $0.recentFoodsSortingStrategy = .carbohydrates
            $0.recentFoodsSortingOrder = .reverse
        }
        await store.receive(\.startObservingRecentFoods)
        continuation.yield([ribeye, eggplant])
        await store.receive(\.didFetchRecentFoods) {
            $0.recentFoods = [ribeye, eggplant]
        }

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [eggplant])
        }
        store.dependencies.databaseClient.delete = {
            XCTAssertNoDifference($0, ribeye)
        }
        await store.send(.didDeleteRecentFoods(.init(integer: 0)))
        await store.send(.didFetchRecentFoods([eggplant])) {
            $0.recentFoods = [eggplant]
        }
        XCTAssertNoDifference(store.state.isCompareButtonDisabled, true)
        XCTAssertNoDifference(store.state.isSortMenuDisabled, true)

        await store.send(.didSelectRecentFood(eggplant)) {
            $0.foodDetails = .init(food: eggplant)
        }

        continuation.finish()
        await store.finish()
    }

    func testMultipleSearchResults() async throws {
        let eggplantApi = FoodApiModel.eggplant
        let eggplant = Food(foodApiModel: eggplantApi)
        let ribeyeApi = FoodApiModel.ribeye
        let ribeye = Food(foodApiModel: ribeyeApi)
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
            },
            withDependencies: {
                $0.mainQueue = .immediate
            }
        )
        store.dependencies.databaseClient.insert = {
            XCTAssertNoDifference($0, eggplant)
            return $0
        }
        await store.send(.didReceiveSearchFoods([eggplantApi, ribeyeApi])) {
            $0.searchResults = [eggplant, ribeye]
        }
        await store.send(.didSelectSearchResult(eggplant)) {
            $0.foodDetails = .init(food: eggplant)
        }
    }

    func testSearchError() async throws {
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
            },
            withDependencies: {
                $0.mainQueue = .immediate
            }
        )
        store.dependencies.foodClient.getFoods = { _ in
            struct FoodError: Error { }
            throw FoodError()
        }
        await store.send(.updateSearchQuery("eggplant")) {
            $0.searchQuery = "eggplant"
        }
        await store.receive(\.startSearching) {
            $0.isSearching = true
        }
        await store.receive(\.didReceiveSearchFoods) {
            $0.shouldShowNoResults = true
            $0.isSearching = false
        }
        await store.receive(\.showGenericAlert) {
            $0.alert = .init {
                TextState("Something went wrong. Please try again later.")
            }
        }
    }

    func testSearchBarFocus() async throws {
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
            },
            withDependencies: {
                $0.mainQueue = .immediate
            }
        )
        await store.send(.updateSearchFocus(true)) {
            $0.isSearchFocused = true
        }
        store.dependencies.databaseClient.insert = {
            XCTAssertNoDifference($0, .eggplant)
            return $0
        }
        await store.send(.didReceiveSearchFoods([.eggplant])) {
            $0.inlineFood = .init(food: .eggplant)
        }
        await store.send(.updateSearchFocus(false)) {
            $0.isSearchFocused = false
            $0.inlineFood = nil
        }
    }

    func testDeletion_error() async throws {
        let store = TestStore(
            initialState: {
                var state = FoodListFeature.State()
                state.recentFoods = [.preview]
                return state
            }(),
            reducer: {
                FoodListFeature()
            },
            withDependencies: {
                $0.databaseClient.delete = { _ in
                    struct Failure: Error { }
                    throw Failure()
                }
            }
        )
        await store.send(.didDeleteRecentFoods(.init(integer: 0)))
        await store.receive(\.showGenericAlert) {
            $0.alert = .init {
                TextState("Something went wrong. Please try again later.")
            }
        }
    }

    func testIntegrationWithSpotlight_foodSelection() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
            }
        )
        store.dependencies.databaseClient.getFood = {
            XCTAssertNoDifference($0, eggplant.name)
            return eggplant
        }
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchableItemActivityIdentifier] = eggplant.name
        await store.send(.spotlight(.handleSelectedFood(activity)))
        await store.receive(\.didSelectRecentFood) {
            $0.foodDetails = .init(food: eggplant)
        }
    }

    func testIntegrationWithSpotlight_search() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: {
                var state = FoodListFeature.State()
                state.foodDetails = .init(food: eggplant)
                return state
            }(),
            reducer: {
                FoodListFeature()
            }
        )
        store.dependencies.mainQueue = .immediate
        store.dependencies.foodClient.getFoods = {
            XCTAssertNoDifference($0, eggplant.name)
            return [.eggplant]
        }
        store.dependencies.databaseClient.insert = {
            XCTAssertNoDifference($0, eggplant)
            return eggplant
        }
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchQueryString] = eggplant.name
        await store.send(.spotlight(.handleSearchInApp(activity)))
        await store.receive(\.foodDetails.dismiss) {
            $0.foodDetails = nil
        }
        await store.receive(\.updateSearchFocus) {
            $0.isSearchFocused = true
        }
        await store.receive(\.updateSearchQuery) {
            $0.searchQuery = eggplant.name
        }
        await store.receive(\.startSearching) {
            $0.isSearching = true
        }
        await store.receive(\.didReceiveSearchFoods) {
            $0.inlineFood = .init(food: eggplant)
            $0.isSearching = false
        }
    }

    func testIntegrationWithBillboard_multipleAds() async throws {
        let firstAd = BillboardAd.preview
        let secondAd = BillboardAd(
            appStoreID: "id",
            name: "secondAd",
            title: "secondTitle",
            description: "secondDescription",
            media: .cachesDirectory,
            backgroundColor: "red",
            textColor: "black",
            tintColor: "blue",
            fullscreen: true,
            transparent: true
        )
        let store = TestStore(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
            }
        )
        store.exhaustivity = .off
        store.dependencies.userDefaults.data = { @Sendable _ in nil }
        store.dependencies.billboardClient.getRandomBanners = {
            .init {
                $0.yield(firstAd)
                $0.yield(nil)
                $0.yield(secondAd)
                $0.finish()
            }
        }
        await store.send(.onAppear)
        await store.receive(\.billboard.showBanner) {
            $0.billboard.banner = firstAd
        }
        await store.receive(\.billboard.showBanner) {
            $0.billboard.banner = nil
        }
        await store.receive(\.billboard.showBanner) {
            $0.billboard.banner = secondAd
        }
    }

    func testIntegrationWithComparisonFeature() async throws {
        let store = TestStore(
            initialState: {
                var state = FoodListFeature.State()
                state.recentFoods = [.eggplant, .ribeye]
                return state
            }(),
            reducer: {
                FoodListFeature()
            }
        )
        await store.send(.didTapCompare) {
            $0.foodComparison = .init(foods: [.eggplant, .ribeye])
        }
    }
}

extension FoodApiModel {
    static let eggplant = FoodApiModel(
        name: "eggplant",
        calories: 34.7,
        servingSizeG: 100,
        fatTotalG: 0.2,
        fatSaturatedG: 0.0,
        proteinG: 0.8,
        sodiumMg: 0.0,
        potassiumMg: 15.0,
        cholesterolMg: 0.0,
        carbohydratesTotalG: 8.7,
        fiberG: 2.5,
        sugarG: 3.2
    )

    static let ribeye = FoodApiModel(
        name: "ribeye",
        calories: 274.1,
        servingSizeG: 100.0,
        fatTotalG: 18.9,
        fatSaturatedG: 8.5,
        proteinG: 24.8,
        sodiumMg: 58.0,
        potassiumMg: 166.0,
        cholesterolMg: 78.0,
        carbohydratesTotalG: 0.0,
        fiberG: 0.0,
        sugarG: 0.0
    )
}

extension Food {
    static var eggplant: Self {
        .init(foodApiModel: .eggplant)
    }

    static var ribeye: Self {
        .init(foodApiModel: .ribeye)
    }
}
