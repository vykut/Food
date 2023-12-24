import XCTest
import ComposableArchitecture
import Shared
import Spotlight
@testable import UserPreferences
@testable import API
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
            state.sortStrategy = .name
            state.sortOrder = .forward
            state.foodSearch = .init(
                sortStrategy: .name,
                sortOrder: .forward
            )
            state.foodObservation = .init(
                sortStrategy: .name,
                sortOrder: .forward
            )
            state.destination = nil
        }
        XCTAssertEqual(store.state.isSortMenuDisabled, true)
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
                        recentSearchesSortStrategy: .energy,
                        recentSearchesSortOrder: .reverse
                    )
                }
                $0.uuid = .constant(.init(0))
            }
        )

        store.assert { state in
            state.sortStrategy = .energy
            state.sortOrder = .reverse
            state.foodSearch = .init(
                sortStrategy: .energy,
                sortOrder: .reverse
            )
            state.foodObservation = .init(
                sortStrategy: .energy,
                sortOrder: .reverse
            )
            state.destination = nil
        }
    }

    func testOnFirstAppear() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient.getPreferences = {
                    .init(
                        recentSearchesSortStrategy: .energy,
                        recentSearchesSortOrder: .reverse
                    )
                }
                $0.uuid = .constant(.init(0))
            }
        )

        await store.send(.onFirstAppear)
    }

    func testUpdateRecentFoodsSortingStrategy() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient.getPreferences = {
                    .init()
                }
                $0.userPreferencesClient.setPreferences = { modify in
                    var prefs = UserPreferences()
                    modify(&prefs)
                    XCTAssertNoDifference(prefs, .init(recentSearchesSortStrategy: .energy, recentSearchesSortOrder: .forward))

                }
                $0.databaseClient.observeFoods = {
                    XCTAssertEqual($0, .energy)
                    XCTAssertEqual($1, .forward)
                    return .finished
                }
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.updateRecentFoodsSortingStrategy(.energy)) {
            $0.sortStrategy = .energy
        }
        await store.receive(\.foodSearch.updateSortStrategy) {
            $0.foodSearch.sortStrategy = .energy
            $0.foodSearch.sortOrder = .forward
        }
        await store.receive(\.foodObservation.updateSortStrategy) {
            $0.foodObservation.sortStrategy = .energy
            $0.foodObservation.sortOrder = .forward
        }
        store.dependencies.userPreferencesClient.setPreferences = { modify in
            var prefs = UserPreferences()
            modify(&prefs)
            XCTAssertNoDifference(prefs, .init(recentSearchesSortStrategy: .energy, recentSearchesSortOrder: .reverse))

        }
        store.dependencies.databaseClient.observeFoods = {
            XCTAssertEqual($0, .energy)
            XCTAssertEqual($1, .reverse)
            return .finished
        }
        await store.send(.updateRecentFoodsSortingStrategy(.energy)) {
            $0.sortStrategy = .energy
            $0.sortOrder = .reverse
        }
        await store.receive(\.foodSearch.updateSortStrategy) {
            $0.foodSearch.sortStrategy = .energy
            $0.foodSearch.sortOrder = .reverse
        }
        await store.receive(\.foodObservation.updateSortStrategy) {
            $0.foodObservation.sortStrategy = .energy
            $0.foodObservation.sortOrder = .reverse
        }
    }

    func testIntegrationWithFoodObservation() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient.getPreferences = {
                    .init()
                }
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.foodObservation(.updateFoods([]))) {
            $0.foodSearch.isFocused = true
        }
        await store.send(.foodObservation(.updateFoods([.eggplant, .ribeye]))) {
            $0.foodObservation.foods = [.eggplant, .ribeye]
        }
        XCTAssertEqual(store.state.isSortMenuDisabled, false)
    }

    func testIntegrationWithFoodSearch() async throws {
        var didSearch = false
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.continuousClock = ImmediateClock()
                $0.userPreferencesClient.getPreferences = {
                    .init()
                }
                $0.uuid = .constant(.init(0))
                $0.databaseClient.getFoods = { q, s, o in
                    if didSearch {
                        [.eggplant, .ribeye]
                    } else {
                        [.ribeye]
                    }
                }
                $0.databaseClient.insertFoods = {
                    XCTAssertNoDifference($0, [.init(foodApiModel: .preview)])
                    return $0
                }
                $0.foodClient.getFoods = { q in
                    didSearch = true
                    return [.eggplant]
                }
            }
        )
        await store.send(.foodSearch(.updateFocus(true))) {
            $0.foodSearch.isFocused = true
        }
        await store.send(.foodSearch(.updateQuery("eggplant"))) {
            $0.foodSearch.query = "eggplant"
        }
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        await store.receive(\.foodSearch.result) {
            $0.foodSearch.searchResults = [.ribeye]
        }
        await store.receive(\.foodSearch.result) {
            $0.foodSearch.searchResults = [.eggplant, .ribeye]
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
    }

    func testRecentFoodSelection() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient.getPreferences = {
                    .init()
                }
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.didSelectRecentFood(.eggplant)) {
            $0.destination = .foodDetails(.init(food: .eggplant))
        }
    }

    func testSearchResultSelection() async throws {
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient.getPreferences = {
                    .init()
                }
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.didSelectSearchResult(.eggplant)) {
            $0.destination = .foodDetails(.init(food: .eggplant))
        }
    }

    func testFoodDeletion() async throws {
        var didDelete = false
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.userPreferencesClient.getPreferences = {
                    .init()
                }
                $0.databaseClient.deleteFoods = {
                    if didDelete {
                        struct Failure: Error { }
                        throw Failure()
                    } else {
                        XCTAssertNoDifference($0, [.ribeye])
                        didDelete = true
                    }
                }
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.foodObservation(.updateFoods([.eggplant, .ribeye]))) {
            $0.foodObservation.foods = [.eggplant, .ribeye]
        }
        await store.send(.didDeleteRecentFoods(.init(integer: 1)))
        await store.send(.didDeleteRecentFoods(.init(integer: 1)))
        await store.receive(\.showGenericAlert) {
            $0.destination = .alert(.init {
                TextState("Something went wrong. Please try again later.")
            })
        }
    }

    func testFullFlowNewInstallation() async throws {
        var (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        let store = TestStore(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
            },
            withDependencies: {
                $0.continuousClock = ImmediateClock()
                $0.userPreferencesClient.getPreferences = {
                    .init()
                }
                $0.uuid = .constant(.init(0))
                $0.databaseClient.observeFoods = { _, _ in stream }
                var didSearch = false
                $0.databaseClient.getFoods = { q, s, o in
                    XCTAssertEqual(q, "eggplant")
                    XCTAssertEqual(s, .name)
                    XCTAssertEqual(o, .forward)
                    return if didSearch {
                        [.eggplant]
                    } else {
                        []
                    }
                }
                $0.databaseClient.insertFoods = { $0 }
                $0.foodClient.getFoods = {
                    XCTAssertEqual($0, "eggplant")
                    didSearch = true
                    return [.eggplant]
                }
            }
        )
        await store.send(.foodObservation(.startObservation))
        continuation.yield([])
        await store.receive(\.foodObservation.updateFoods) {
            $0.foodSearch.isFocused = true
        }

        // search
        await store.send(.foodSearch(.updateQuery("eggplant"))) {
            $0.foodSearch.query = "eggplant"
        }
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        await store.receive(\.foodSearch.result)
        await store.receive(\.foodSearch.result) {
            $0.foodSearch.searchResults = [.eggplant]
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
        continuation.yield([.eggplant])
        await store.receive(\.foodObservation.updateFoods) {
            $0.foodObservation.foods = [.eggplant]
        }

        // food details
        await store.send(.didSelectSearchResult(.eggplant)) {
            $0.destination = .foodDetails(.init(food: .eggplant))
        }
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }

        // search
        var didSearch = false
        store.dependencies.databaseClient.getFoods = { q, s, o in
            XCTAssertEqual(q, "ribeye")
            XCTAssertEqual(s, .name)
            XCTAssertEqual(o, .forward)
            return if didSearch {
                [.ribeye]
            } else {
                []
            }
        }
        store.dependencies.foodClient.getFoods = {
            XCTAssertEqual($0, "ribeye")
            didSearch = true
            return [.ribeye]
        }
        await store.send(.foodSearch(.updateQuery("ribeye"))) {
            $0.foodSearch.query = "ribeye"
        }
        await store.receive(\.foodSearch.searchStarted) {
            $0.foodSearch.isSearching = true
        }
        await store.receive(\.foodSearch.result) {
            $0.foodSearch.searchResults = []
        }
        await store.receive(\.foodSearch.result) {
            $0.foodSearch.searchResults = [.ribeye]
        }
        await store.receive(\.foodSearch.searchEnded) {
            $0.foodSearch.isSearching = false
        }
        continuation.yield([.eggplant, .ribeye])
        await store.receive(\.foodObservation.updateFoods) {
            $0.foodObservation.foods = [.eggplant, .ribeye]
        }

        // food details
        await store.send(.foodSearch(.updateQuery(""))) {
            $0.foodSearch.query = ""
            $0.foodSearch.searchResults = []
        }
        await store.send(.foodSearch(.updateFocus(false))) {
            $0.foodSearch.isFocused = false
        }
        await store.send(.didSelectRecentFood(.ribeye)) {
            $0.destination = .foodDetails(.init(food: .ribeye))
        }
        XCTAssertEqual(store.state.isSortMenuDisabled, false)

        // sort strategy
        (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = {
            XCTAssertEqual($0, .fat)
            XCTAssertEqual($1, .forward)
            return stream
        }
        store.dependencies.userPreferencesClient.setPreferences = { modify in
            var prefs = UserPreferences()
            modify(&prefs)
            XCTAssertNoDifference(prefs, .init(recentSearchesSortStrategy: .fat, recentSearchesSortOrder: .forward))
        }
        await store.send(.updateRecentFoodsSortingStrategy(.fat)) {
            $0.sortStrategy = .fat
            $0.sortOrder = .forward
        }
        await store.receive(\.foodSearch.updateSortStrategy) {
            $0.foodSearch.sortStrategy = .fat
            $0.foodSearch.sortOrder = .forward
        }
        await store.receive(\.foodObservation.updateSortStrategy) {
            $0.foodObservation.sortStrategy = .fat
            $0.foodObservation.sortOrder = .forward
        }
        continuation.yield([.ribeye, .eggplant])
        await store.receive(\.foodObservation.updateFoods) {
            $0.foodObservation.foods = [.ribeye, .eggplant]
        }

        // delete
        store.dependencies.databaseClient.deleteFoods = { _ in }
        await store.send(.didDeleteRecentFoods([0, 1]))
        continuation.yield([])
        await store.receive(\.foodObservation.updateFoods) {
            $0.foodObservation.foods = []
            $0.foodSearch.isFocused = true
        }

        continuation.finish()
        await store.finish()
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
