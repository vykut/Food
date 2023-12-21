import XCTest
import ComposableArchitecture
import Shared
import Spotlight
@testable import UserPreferences
@testable import API
@testable import Billboard
@testable import FoodList

@MainActor
final class FoodListTests: XCTestCase {
    func testStateDefaultInitializer() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            }
        )

        store.assert { state in
            state.recentFoodsSortingStrategy = .name
            state.recentFoodsSortingOrder = .forward
            state.foodSearch = .init()
            state.recentFoods = []
            state.searchResults = []
            state.shouldShowNoResults = false
            state.destination = nil
            state.billboard = .init(banner: nil)
        }
    }

    func test_onTask() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient = .init(
                    getPreferences: {
                        .init(
                            recentSearchesSortingStrategy: FoodList.State.SortingStrategy.energy.rawValue,
                            recentSearchesSortingOrder: .reverse
                        )
                    },
                    setPreferences: { _ in
                        XCTFail()
                    },
                    observeChanges: {
                        .finished
                    }
                )
            }
        )
        let (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [])
        }
        store.dependencies.billboardClient.getRandomBanners = {
            .finished()
        }
        store.dependencies.databaseClient.observeFoods = { strategy, order in
            XCTAssertEqual(strategy.name, "energy")
            XCTAssertEqual(order, .reverse)
            return stream
        }

        await store.send(.onFirstAppear)
        await store.receive(\.startObservingRecentFoods)
        continuation.yield([])
        await store.receive(\.onRecentFoodsChange) {
            $0.foodSearch.isFocused = true
        }
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, false)
        XCTAssertNoDifference(store.state.shouldShowPrompt, true)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.shouldShowSearchResults, false)
        continuation.finish()
        await store.finish()
    }

    func test_onTask_hasRecentFoods() async throws {
        let food = Food.preview
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient = .init(
                    getPreferences: {
                        .init(
                            recentSearchesSortingStrategy: FoodList.State.SortingStrategy.energy.rawValue,
                            recentSearchesSortingOrder: .reverse
                        )
                    },
                    setPreferences: { _ in

                    },
                    observeChanges: {
                        .finished
                    }
                )
            }
        )
        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [food])
        }
        store.dependencies.billboardClient.getRandomBanners = {
            .finished()
        }
        let (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = { strategy, order in
            XCTAssertEqual(strategy.name, "energy")
            XCTAssertEqual(order, .reverse)
            return stream
        }

        await store.send(.onFirstAppear)
        await store.receive(\.startObservingRecentFoods)
        continuation.yield([food])
        await store.receive(\.onRecentFoodsChange) {
            $0.recentFoods = [food]
        }

        XCTAssertNoDifference(store.state.foodSearch.isFocused, false)
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
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.mainQueue = .immediate
                $0.userPreferencesClient = .init(
                    getPreferences: {
                        .init(
                            recentSearchesSortingStrategy: FoodList.State.SortingStrategy.energy.rawValue,
                            recentSearchesSortingOrder: .reverse
                        )
                    },
                    setPreferences: { _ in

                    },
                    observeChanges: {
                        .finished
                    }
                )
                $0.spotlightClient.indexFoods = {
                    XCTAssertNoDifference($0, [])
                }
                $0.billboardClient.getRandomBanners = {
                    .init {
                        $0.yield(.preview)
                        $0.finish()
                    }
                }
                $0.databaseClient.numberOfFoods = { _ in 0 }
                $0.databaseClient.insertFoods = { $0 }
            }
        )
        var (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = { strategy, order in
            XCTAssertEqual(strategy.name, "energy")
            XCTAssertEqual(order, .reverse)
            return stream
        }

        await store.send(.onFirstAppear)
        await store.receive(\.startObservingRecentFoods)
        await store.receive(\.billboard.showBanner) {
            $0.billboard.banner = .preview
        }
        continuation.yield([])
        await store.receive(\.onRecentFoodsChange) {
            $0.foodSearch.isFocused = true
        }
        XCTAssertNoDifference(store.state.isSortMenuDisabled, true)
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, false)
        XCTAssertNoDifference(store.state.shouldShowPrompt, true)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.shouldShowSearchResults, false)

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [eggplant])
        }
        store.dependencies.foodClient.getFoods = { _ in [] }
        store.dependencies.databaseClient.numberOfFoods = { _ in 1 }
        store.dependencies.databaseClient.getFoods = { _, _, _ in [eggplant] }
        await store.send(.foodSearch(.updateQuery("C"))) {
            $0.foodSearch.query = "C"
            $0.shouldShowNoResults = false
            $0.searchResults = []
        }
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        XCTAssertEqual(store.state.shouldShowSpinner, true)
        await store.receive(\.foodSearch.delegate.result) {
            $0.searchResults = [.preview]
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
        XCTAssertEqual(store.state.shouldShowSpinner, false)
        continuation.yield([eggplant])
        await store.receive(\.onRecentFoodsChange) {
            $0.recentFoods = [eggplant]
        }
        XCTAssertNoDifference(store.state.isSortMenuDisabled, true)

        await store.send(.foodSearch(.updateQuery(""))) {
            $0.foodSearch.query = ""
            $0.shouldShowNoResults = false
            $0.foodSearch.isSearching = false
        }
        store.exhaustivity = .off
        store.dependencies.foodClient.getFoods = { _ in [] }
        await store.send(.foodSearch(.updateQuery("R")))
        await store.send(.foodSearch(.updateQuery("Ri")))
        await store.send(.foodSearch(.updateQuery("Rib")))
        await store.send(.foodSearch(.updateQuery("Ribe")))
        await store.send(.foodSearch(.updateQuery("Ribey")))
        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [ribeye, eggplant])
        }
        store.dependencies.databaseClient.getFoods = { _, _, _ in [ribeye] }
        await store.send(.foodSearch(.updateQuery("Ribeye"))) {
            $0.foodSearch.query = "Ribeye"
            $0.shouldShowNoResults = false
        }
        store.exhaustivity = .on
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        await store.receive(\.foodSearch.delegate.result) {
            $0.searchResults = [ribeye]
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
        await store.send(.onRecentFoodsChange([ribeye, eggplant])) {
            $0.recentFoods = [ribeye, eggplant]
        }
        XCTAssertNoDifference(store.state.isSortMenuDisabled, false)

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [eggplant, ribeye])
        }
        (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = { strategy, order in
            XCTAssertEqual(strategy.name, "carbohydrate")
            XCTAssertEqual(order, .forward)
            return stream
        }
        store.dependencies.userPreferencesClient.setPreferences = { modify in
            var prefs = UserPreferences()
            modify(&prefs)
            XCTAssertNoDifference(prefs, .init(recentSearchesSortingStrategy: "carbohydrate", recentSearchesSortingOrder: .forward))
        }
        await store.send(.updateRecentFoodsSortingStrategy(.carbohydrate)) {
            $0.recentFoodsSortingStrategy = .carbohydrate
            $0.recentFoodsSortingOrder = .forward
        }
        await store.receive(\.startObservingRecentFoods)
        continuation.yield([eggplant, ribeye])
        await store.receive(\.onRecentFoodsChange) {
            $0.recentFoods = [eggplant, ribeye]
        }
        XCTAssertNoDifference(store.state.isSortMenuDisabled, false)

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [ribeye, eggplant])
        }
        (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = { strategy, order in
            XCTAssertEqual(strategy.name, "carbohydrate")
            XCTAssertEqual(order, .reverse)
            return stream
        }
        store.dependencies.userPreferencesClient.setPreferences = { modify in
            var prefs = UserPreferences()
            modify(&prefs)
            XCTAssertNoDifference(prefs, .init(recentSearchesSortingStrategy: "carbohydrate", recentSearchesSortingOrder: .reverse))
        }
        await store.send(.updateRecentFoodsSortingStrategy(.carbohydrate)) {
            $0.recentFoodsSortingStrategy = .carbohydrate
            $0.recentFoodsSortingOrder = .reverse
        }
        await store.receive(\.startObservingRecentFoods)
        continuation.yield([ribeye, eggplant])
        await store.receive(\.onRecentFoodsChange) {
            $0.recentFoods = [ribeye, eggplant]
        }

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [eggplant])
        }
        store.dependencies.databaseClient.deleteFood = {
            XCTAssertNoDifference($0, ribeye)
        }
        await store.send(.didDeleteRecentFoods(.init(integer: 0)))
        await store.send(.onRecentFoodsChange([eggplant])) {
            $0.recentFoods = [eggplant]
        }
        XCTAssertNoDifference(store.state.isSortMenuDisabled, true)

        await store.send(.didSelectRecentFood(eggplant)) {
            $0.destination = .foodDetails(.init(food: eggplant))
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
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.mainQueue = .immediate
                $0.databaseClient.numberOfFoods = { _ in 2 }
                $0.databaseClient.getFoods = { _, _, _ in [eggplant, ribeye] }
                $0.foodClient.getFoods = { _ in [] }
            }
        )
        await store.send(.foodSearch(.updateFocus(true))) {
            $0.foodSearch.isFocused = true
        }
        await store.send(.foodSearch(.updateQuery("asd"))) {
            $0.foodSearch.query = "asd"
        }
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        await store.receive(\.foodSearch.delegate.result) {
            $0.searchResults = [eggplant, ribeye]
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
        await store.send(.didSelectSearchResult(eggplant)) {
            $0.destination = .foodDetails(.init(food: eggplant))
        }
    }

    func testSearchError() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.mainQueue = .immediate
                $0.databaseClient.numberOfFoods = { _ in 0 }
            }
        )
        store.dependencies.foodClient.getFoods = { _ in
            struct FoodError: Error { }
            throw FoodError()
        }
        await store.send(.foodSearch(.updateQuery("eggplant"))) {
            $0.foodSearch.query = "eggplant"
        }
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        await store.receive(\.foodSearch.delegate.result)
        await store.receive(\.foodSearch.delegate.error) {
            $0.destination = .alert(.init {
                TextState("Something went wrong. Please try again later.")
            })
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
            $0.shouldShowNoResults = true
        }
    }

    func testSearchBarFocus() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.mainQueue = .immediate
            }
        )
        await store.send(.foodSearch(.updateFocus(true))) {
            $0.foodSearch.isFocused = true
        }
        await store.send(.foodSearch(.updateFocus((false)))) {
            $0.foodSearch.isFocused = false
        }
    }

    func testDeletion_error() async throws {
        let store = TestStore(
            initialState: {
                var state = FoodList.State()
                state.recentFoods = [.preview]
                return state
            }(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.databaseClient.deleteFood = { _ in
                    struct Failure: Error { }
                    throw Failure()
                }
            }
        )
        await store.send(.didDeleteRecentFoods(.init(integer: 0)))
        await store.receive(\.showGenericAlert) {
            $0.destination = .alert(.init {
                TextState("Something went wrong. Please try again later.")
            })
        }
    }

    func testIntegrationWithSpotlight_foodSelection() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
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
            $0.destination = .foodDetails(.init(food: eggplant))
        }
    }

    func testIntegrationWithSpotlight_search() async throws {
        let eggplant = Food.eggplant
        let store = TestStore(
            initialState: {
                var state = FoodList.State()
                state.destination = .foodDetails(.init(food: eggplant))
                return state
            }(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.mainQueue = .immediate
                $0.foodClient.getFoods = { _ in [] }
                $0.databaseClient.numberOfFoods = { _ in 1 }
                $0.databaseClient.getFoods = { _, _, _ in [eggplant] }
            }
        )
        let activity = NSUserActivity(activityType: "mock")
        activity.userInfo?[CSSearchQueryString] = eggplant.name
        await store.send(.spotlight(.handleSearchInApp(activity)))
        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
        await store.receive(\.foodSearch.updateFocus) {
            $0.foodSearch.isFocused = true
        }
        await store.receive(\.foodSearch.updateQuery) {
            $0.foodSearch.query = eggplant.name
        }
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        await store.receive(\.foodSearch.delegate.result) {
            $0.searchResults = [eggplant]
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
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
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            }
        )
        store.exhaustivity = .off
        store.dependencies.userPreferencesClient = .init(
            getPreferences: {
                .init(
                    recentSearchesSortingStrategy: FoodList.State.SortingStrategy.energy.rawValue,
                    recentSearchesSortingOrder: .reverse
                )
            },
            setPreferences: { _ in

            },
            observeChanges: {
                .finished
            }
        )
        store.dependencies.billboardClient.getRandomBanners = {
            .init {
                $0.yield(firstAd)
                $0.yield(nil)
                $0.yield(secondAd)
                $0.finish()
            }
        }
        await store.send(.onFirstAppear)
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
