import Foundation
import XCTest
import Shared
import ComposableArchitecture
@testable import Search

@MainActor
final class FoodSearchTests: XCTestCase {
    func testStateInitialization() async throws {
        let store = TestStore(
            initialState: FoodSearch.State(),
            reducer: {
                FoodSearch()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        store.assert {
            $0.query = ""
            $0.isFocused = false
            $0.isSearching = false
        }
    }

    func testFocus() async throws {
        let store = TestStore(
            initialState: FoodSearch.State(),
            reducer: {
                FoodSearch()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.updateFocus(true)) {
            $0.isFocused = true
        }
        await store.send(.updateFocus(false)) {
            $0.isFocused = false
        }
    }

    func testQuery() async throws {
        let didInsert = ActorIsolated(false)
        let store = TestStore(
            initialState: FoodSearch.State(),
            reducer: {
                FoodSearch()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.mainQueue = .immediate
                $0.foodClient.getFoods = { _ in [.preview] }
                $0.databaseClient.numberOfFoods = { _ in 1 }
                $0.databaseClient.getFoods = { _, _, _ in
                    if await didInsert.value {
                        [.chiliPepper, .init(foodApiModel: .preview)]
                    } else {
                        [.chiliPepper]
                    }
                }
                $0.databaseClient.insertFoods = {
                    await didInsert.setValue(true)
                    return $0
                }
            }
        )
        await store.send(.updateQuery("asd")) {
            $0.query = "asd"
        }
        await store.receive(\.searchStarted) {
            $0.isSearching = true
        }
        await store.receive(\.searchEnded) {
            $0.isSearching = false
        }
        await store.send(.updateQuery("asd"))
        await store.send(.updateQuery("")) {
            $0.query = ""
        }
    }

    func testQueryError() async throws {
        let store = TestStore(
            initialState: FoodSearch.State(),
            reducer: {
                FoodSearch()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.mainQueue = .immediate
                $0.foodClient.getFoods = { _ in
                    struct Failure: Error { }
                    throw Failure()
                }
                $0.databaseClient.numberOfFoods = { _ in 0 }
            }
        )
        await store.send(.updateQuery("asd")) {
            $0.query = "asd"
        }
        await store.receive(\.searchStarted) {
            $0.isSearching = true
        }
        await store.receive(\.error)
        await store.receive(\.searchEnded) {
            $0.isSearching = false
        }
    }

    func testSearchSubmitted() async throws {
        let store = TestStore(
            initialState: {
                var state = FoodSearch.State()
                state.query = "asd"
                return state
            }(),
            reducer: {
                FoodSearch()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.mainQueue = .immediate
                $0.foodClient.getFoods = { _ in [] }
                $0.databaseClient.numberOfFoods = { _ in 1 }
                $0.databaseClient.getFoods = { _, _, _ in [.chiliPepper] }
            }
        )
        await store.send(.searchSubmitted)
        await store.receive(\.searchStarted) {
            $0.isSearching = true
        }
        await store.receive(\.searchEnded) {
            $0.isSearching = false
        }
    }
}

fileprivate extension Food {
    static var chiliPepper: Self {
        .init(
            id: 1,
            name: "chili pepper",
            energy: .kcal(39.4),
            fatTotal: .grams(0.4),
            fatSaturated: .zero,
            protein: .grams(1.9),
            sodium: .grams(0.008),
            potassium: .grams(0.043),
            cholesterol: .zero,
            carbohydrate: .grams(8.8),
            fiber: .grams(1.5),
            sugar: .grams(5.3)
        )
    }

    static var redWineVinegar: Self {
        .init(
            id: 7,
            name: "red wine vinegar",
            energy: .kcal(18.9),
            fatTotal: .zero,
            fatSaturated: .zero,
            protein: .grams(0.1),
            sodium: .grams(0.008),
            potassium: .grams(0.007),
            cholesterol: .zero,
            carbohydrate: .grams(0.3),
            fiber: .zero,
            sugar: .zero
        )
    }
}
