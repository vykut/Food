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
            },
            withDependencies: {
                $0.userPreferencesClient.getPreferences = { .init() }
                $0.uuid = .constant(.init(0))
            }
        )

        store.assert { state in
            state.foodSearch = .init(
                foodObservation: .init(
                    sortStrategy: .name,
                    sortOrder: .forward
                )
            )
            state.billboard = .init(banner: nil)
            state.destination = nil
        }
    }

    func testStateDefaultInitializer_hasUserPreferences() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient.getPreferences = {
                    .init(
                        recentSearchesSortingStrategy: "energy",
                        recentSearchesSortingOrder: .reverse
                    )
                }
                $0.uuid = .constant(.init(0))
            }
        )

        store.assert { state in
            state.foodSearch = .init(
                foodObservation: .init(
                    sortStrategy: .energy,
                    sortOrder: .reverse
                )
            )
            state.billboard = .init(banner: nil)
            state.destination = nil
        }
    }

    func test_onFirstAppear() async throws {
        let (stream, continuation) = AsyncStream.makeStream(of: UserPreferences.self)
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient.getPreferences = {
                    .init(
                        recentSearchesSortingStrategy: "energy",
                        recentSearchesSortingOrder: .reverse
                    )
                }
                $0.userPreferencesClient.observeChanges = { stream }
                $0.spotlightClient.indexFoods = {
                    XCTAssertNoDifference($0, [])
                }
                $0.billboardClient.getRandomBanners = {
                    .finished()
                }
                $0.uuid = .constant(.init(0))
            }
        )

        await store.send(.onFirstAppear)
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, false)
        XCTAssertNoDifference(store.state.shouldShowPrompt, true)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        continuation.yield(.init(recentSearchesSortingStrategy: "energy", recentSearchesSortingOrder: .forward))
        await store.receive(\.onUserPreferencesChange)
        await store.receive(\.foodSearch.foodObservation.updateSortStrategy) {
            $0.foodSearch.foodObservation.sortOrder = .forward
        }
        continuation.finish()
        await store.finish()
    }

    func testFullFlow_newInstallation() async throws {
        var (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
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
                $0.uuid = .constant(.init(0))
                $0.mainQueue = .immediate
                $0.userPreferencesClient = .init(
                    getPreferences: {
                        .init(
                            recentSearchesSortingStrategy: "energy",
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
                $0.databaseClient.observeFoods = { strategy, order in
                    XCTAssertEqual(strategy.name, "energy")
                    XCTAssertEqual(order, .reverse)
                    return stream
                }
            }
        )

        await store.send(.onFirstAppear)
        await store.receive(\.billboard.showBanner) {
            $0.billboard.banner = .preview
        }
        await store.send(.foodSearch(.foodObservation(.startObservation)))
        continuation.yield([])
        await store.receive(\.foodSearch.foodObservation.updateFoods) {
            $0.foodSearch.isFocused = true
        }
        XCTAssertNoDifference(store.state.isSortMenuDisabled, true)
        XCTAssertNoDifference(store.state.shouldShowRecentSearches, false)
        XCTAssertNoDifference(store.state.shouldShowPrompt, true)
        XCTAssertNoDifference(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.foodSearch.shouldShowSearchResults, false)

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [eggplant])
        }
        store.dependencies.foodClient.getFoods = { _ in [] }
        await store.send(.foodSearch(.updateQuery("C"))) {
            $0.foodSearch.query = "C"
        }
        XCTAssertEqual(store.state.foodSearch.searchResults, [])
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        XCTAssertEqual(store.state.foodSearch.shouldShowSearchResults, true)
        XCTAssertEqual(store.state.foodSearch.shouldShowNoResults, false)
        XCTAssertEqual(store.state.shouldShowSpinner, true)
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
        continuation.yield([eggplant])
        await store.receive(\.foodSearch.foodObservation.updateFoods) {
            $0.foodSearch.foodObservation.foods = [eggplant]
        }
        XCTAssertEqual(store.state.shouldShowSpinner, false)
        XCTAssertNoDifference(store.state.isSortMenuDisabled, true)

        await store.send(.foodSearch(.updateQuery(""))) {
            $0.foodSearch.query = ""
            $0.foodSearch.isSearching = false
        }
        XCTAssertEqual(store.state.foodSearch.shouldShowNoResults, false)
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
        }
        store.exhaustivity = .on
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
        continuation.yield([ribeye, eggplant])
        XCTAssertEqual(store.state.foodSearch.shouldShowNoResults, true)
        await store.receive(\.foodSearch.foodObservation.updateFoods) {
            $0.foodSearch.foodObservation.foods = [ribeye, eggplant]
        }
        XCTAssertEqual(store.state.foodSearch.shouldShowNoResults, false)
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
        await store.send(.updateRecentFoodsSortingStrategy(.carbohydrate))
        await store.send(.foodSearch(.foodObservation(.updateSortStrategy(.carbohydrate, .forward)))) {
            $0.foodSearch.foodObservation.sortStrategy = .carbohydrate
            $0.foodSearch.foodObservation.sortOrder = .forward
        }
        continuation.yield([eggplant, ribeye])
        await store.receive(\.foodSearch.foodObservation.updateFoods) {
            $0.foodSearch.foodObservation.foods = [eggplant, ribeye]
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
        await store.send(.updateRecentFoodsSortingStrategy(.carbohydrate))
        await store.send(.foodSearch(.foodObservation(.updateSortStrategy(.carbohydrate, .reverse)))) {
            $0.foodSearch.foodObservation.sortStrategy = .carbohydrate
            $0.foodSearch.foodObservation.sortOrder = .reverse
        }
        continuation.yield([ribeye, eggplant])
        await store.receive(\.foodSearch.foodObservation.updateFoods) {
            $0.foodSearch.foodObservation.foods = [ribeye, eggplant]
        }

        store.dependencies.spotlightClient.indexFoods = {
            XCTAssertNoDifference($0, [eggplant])
        }
        store.dependencies.databaseClient.deleteFoods = {
            XCTAssertNoDifference($0, [ribeye])
        }
        await store.send(.didDeleteRecentFoods(.init(integer: 0)))
        await store.send(.foodSearch(.foodObservation(.updateFoods([eggplant])))) {
            $0.foodSearch.foodObservation.foods = [eggplant]
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
                $0.uuid = .constant(.init(0))
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
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
        await store.send(.didSelectSearchResult(eggplant)) {
            $0.destination = .foodDetails(.init(food: eggplant))
        }
    }

    func testSearchError() async throws {

        let store = TestStore(
            initialState: {
                var state = FoodList.State()
                state.foodSearch.isFocused = true
                return state
            }(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.mainQueue = .immediate
                $0.databaseClient.numberOfFoods = { _ in 0 }
                $0.uuid = .constant(.init(0))
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
        await store.receive(\.foodSearch.error) {
            $0.destination = .alert(.init {
                TextState("Something went wrong. Please try again later.")
            })
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
        XCTAssertEqual(store.state.foodSearch.shouldShowNoResults, true)
    }

    func testSearchBarFocus() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.mainQueue = .immediate
                $0.uuid = .constant(.init(0))
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
                state.foodSearch.foodObservation.foods = [.preview]
                return state
            }(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.databaseClient.deleteFoods = { _ in
                    struct Failure: Error { }
                    throw Failure()
                }
                $0.uuid = .constant(.init(0))
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
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
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
                $0.uuid = .constant(.init(0))
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
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        store.exhaustivity = .off
        store.dependencies.userPreferencesClient = .init(
            getPreferences: {
                .init(
                    recentSearchesSortingStrategy: "energy",
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
