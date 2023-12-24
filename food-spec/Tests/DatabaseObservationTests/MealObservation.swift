import Foundation
import Shared
import XCTest
import ComposableArchitecture
@testable import DatabaseObservation

@MainActor
final class MealObservationTests: XCTestCase {
    func testStateInitialization() async throws {
        let store = TestStore(
            initialState: MealObservation.State(),
            reducer: {
                MealObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        store.assert {
            $0.sortStrategy = .name
            $0.sortOrder = .forward
        }
    }

    func testStartObservation() async throws {
        let store = TestStore(
            initialState: MealObservation.State(),
            reducer: {
                MealObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.startObservation)
    }

    func testUpdateMeals() async throws {
        let store = TestStore(
            initialState: MealObservation.State(),
            reducer: {
                MealObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.delegate(.mealsChanged([.chimichurri, .mock(id: 23, ingredients: [])])))
        await store.send(.delegate(.mealsChanged([])))
    }

    func testUpdateSortStrategy() async throws {
        let store = TestStore(
            initialState: MealObservation.State(),
            reducer: {
                MealObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        await store.send(.updateSortStrategy(.name, .reverse)) {
            $0.sortStrategy = .name
            $0.sortOrder = .reverse
        }
        store.dependencies.databaseClient.observeMeals = { _, _ in
            XCTFail()
            return .finished
        }
        await store.send(.updateSortStrategy(.name, .reverse))
    }

    func testFullFlow() async throws {
        var (stream, continuation) = AsyncStream.makeStream(of: [Meal].self)
        let store = TestStore(
            initialState: MealObservation.State(),
            reducer: {
                MealObservation()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.databaseClient.observeMeals = { s, o in
                    XCTAssertEqual(s, .name)
                    XCTAssertEqual(o, .forward)
                    return stream
                }
            }
        )
        await store.send(.startObservation)
        continuation.yield([.chimichurri])
        await store.receive(.delegate(.mealsChanged([.chimichurri])))
        continuation.yield([.chimichurri, .mock(id: 123, ingredients: [])])
        await store.receive(.delegate(.mealsChanged([.chimichurri, .mock(id: 123, ingredients: [])])))
        (stream, continuation) = AsyncStream.makeStream(of: [Meal].self)
        store.dependencies.databaseClient.observeMeals = { s, o in
            XCTAssertEqual(s, .name)
            XCTAssertEqual(o, .reverse)
            return stream
        }
        await store.send(.updateSortStrategy(.name, .reverse)) {
            $0.sortOrder = .reverse
        }
        continuation.yield([.mock(id: 123, ingredients: []), .chimichurri])
        await store.receive(.delegate(.mealsChanged([.mock(id: 123, ingredients: []), .chimichurri])))

        continuation.finish()
        await store.finish()
    }
}

fileprivate extension Meal {
    static func mock(id: Int64, ingredients: [Food]) -> Self {
        .init(
            id: id,
            name: ingredients.map(\.name).joined(),
            ingredients: ingredients.map { .init(food: $0, quantity: .grams(100)) },
            servings: 1,
            instructions: ""
        )
    }

    static var chimichurri: Self {
        Meal(
            name: "Chimichurri",
            ingredients: [
                .init(
                    food: .chiliPepper,
                    quantity: .init(value: 3, unit: .tablespoons)
                ),
                .init(
                    food: .coriander,
                    quantity: .grams(100)
                ),
                .init(
                    food: .garlic,
                    quantity: .init(value: 0.25, unit: .cups)
                ),
                .init(
                    food: .oliveOil,
                    quantity: .init(value: 0.5, unit: .cups)
                ),
                .init(
                    food: .oregano,
                    quantity: .init(value: 1, unit: .teaspoons)
                ),
                .init(
                    food: .parsley,
                    quantity: .init(value: 0.5, unit: .cups)
                ),
                .init(
                    food: .redWineVinegar,
                    quantity: .init(value: 2, unit: .tablespoons)
                ),
            ],
            servings: 10,
            instructions: "Mix well"
        )
    }
}

fileprivate extension Food {
    static var zero: Self {
        .init(
            name: "",
            energy: .zero,
            fatTotal: .zero,
            fatSaturated: .zero,
            protein: .zero,
            sodium: .zero,
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .zero,
            fiber: .zero,
            sugar: .zero
        )
    }

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

    static var coriander: Self {
        .init(
            id: 2,
            name: "coriander",
            energy: .kcal(306.3),
            fatTotal: .grams(17.8),
            fatSaturated: .grams(1.1),
            protein: .grams(12.3),
            sodium: .grams(0.034),
            potassium: .grams(0.405),
            cholesterol: .zero,
            carbohydrate: .grams(55.2),
            fiber: .grams(41),
            sugar: .zero
        )
    }

    static var garlic: Self {
        .init(
            id: 3,
            name: "garlic",
            energy: .kcal(144.8),
            fatTotal: .grams(0.7),
            fatSaturated: .zero,
            protein: .grams(6.4),
            sodium: .grams(0.016),
            potassium: .grams(0.153),
            cholesterol: .zero,
            carbohydrate: .grams(32.5),
            fiber: .grams(2),
            sugar: .grams(1)
        )
    }

    static var oliveOil: Self {
        .init(
            id: 4,
            name: "olive oil",
            energy: .kcal(869.2),
            fatTotal: .grams(101.2),
            fatSaturated: .grams(13.9),
            protein: .zero,
            sodium: .milligrams(1),
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .zero,
            fiber: .zero,
            sugar: .zero
        )
    }

    static var oregano: Self {
        .init(
            id: 5,
            name: "oregano",
            energy: .kcal(269),
            fatTotal: .grams(4),
            fatSaturated: .grams(2),
            protein: .grams(9),
            sodium: .grams(0.025),
            potassium: .grams(0.147),
            cholesterol: .zero,
            carbohydrate: .grams(69.1),
            fiber: .grams(42.2),
            sugar: .grams(4)
        )
    }

    static var parsley: Self {
        .init(
            id: 6,
            name: "parsley",
            energy: .kcal(36.1),
            fatTotal: .grams(0.8),
            fatSaturated: .grams(0.3),
            protein: .grams(2.9),
            sodium: .grams(0.056),
            potassium: .grams(0.058),
            cholesterol: .zero,
            carbohydrate: .grams(6.2),
            fiber: .grams(3.5),
            sugar: .grams(0.8)
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
