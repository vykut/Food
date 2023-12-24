import Foundation
import Shared
import XCTest
import ComposableArchitecture
@testable import FoodObservation

@MainActor
final class FoodObservationTests: XCTestCase {
    func testStateInitialization() async throws {
        let store = TestStore(
            initialState: FoodObservation.State(),
            reducer: {
                FoodObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        store.assert {
            $0.foods = []
            $0.sortStrategy = .name
            $0.sortOrder = .forward
        }
    }

    func testStartObservation() async throws {
        let store = TestStore(
            initialState: FoodObservation.State(),
            reducer: {
                FoodObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.databaseClient.observeFoods = { s, o in
                    XCTAssertEqual(s, .name)
                    XCTAssertEqual(o, .forward)
                    return .finished
                }
            }
        )
        await store.send(.startObservation)
    }

    func testUpdateFoods() async throws {
        let store = TestStore(
            initialState: FoodObservation.State(),
            reducer: {
                FoodObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.updateFoods([.chiliPepper, .redWineVinegar])) {
            $0.foods = [.chiliPepper, .redWineVinegar]
        }
        await store.send(.updateFoods([])) {
            $0.foods = []
        }
    }

    func testUpdateSortStrategy() async throws {
        let store = TestStore(
            initialState: FoodObservation.State(),
            reducer: {
                FoodObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.databaseClient.observeFoods = { s, o in
                    XCTAssertEqual(s, .protein)
                    XCTAssertEqual(o, .reverse)
                    return .finished
                }
            }
        )
        await store.send(.updateSortStrategy(.protein, .reverse)) {
            $0.sortStrategy = .protein
            $0.sortOrder = .reverse
        }
        store.dependencies.databaseClient.observeFoods = { _, _ in
            XCTFail()
            return .finished
        }
        await store.send(.updateSortStrategy(.protein, .reverse))
    }

    func testFullFlow() async throws {
        var (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        let store = TestStore(
            initialState: FoodObservation.State(),
            reducer: {
                FoodObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.databaseClient.observeFoods = { s, o in
                    XCTAssertEqual(s, .name)
                    XCTAssertEqual(o, .forward)
                    return stream
                }
            }
        )
        await store.send(.startObservation)
        continuation.yield([.chiliPepper])
        await store.receive(\.updateFoods) {
            $0.foods = [.chiliPepper]
        }
        continuation.yield([.chiliPepper, .redWineVinegar]) 
        await store.receive(\.updateFoods) {
            $0.foods = [.chiliPepper, .redWineVinegar]
        }
        (stream, continuation) = AsyncStream.makeStream(of: [Food].self)
        store.dependencies.databaseClient.observeFoods = { s, o in
            XCTAssertEqual(s, .name)
            XCTAssertEqual(o, .reverse)
            return stream
        }
        await store.send(.updateSortStrategy(.name, .reverse)) {
            $0.sortOrder = .reverse
        }
        continuation.yield([.redWineVinegar, .chiliPepper])
        await store.receive(\.updateFoods) {
            $0.foods = [.redWineVinegar, .chiliPepper]
        }

        continuation.finish()
        await store.finish()
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
