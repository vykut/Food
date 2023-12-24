import XCTest
import ComposableArchitecture
import Spotlight
import Shared
@testable import TabBar

@MainActor
final class SpotlightReducerTests: XCTestCase {
    func testStart() async throws {
        let (foodStream, foodContinuation) = AsyncStream.makeStream(of: [Food].self)
        let (mealStream, mealContinuation) = AsyncStream.makeStream(of: [Meal].self)
        let chiliPepper = Food.chiliPepper
        let redWineVinegar = Food.redWineVinegar
        let foods = [chiliPepper, redWineVinegar]
        let store = TestStore(
            initialState: SpotlightReducer.State(),
            reducer: {
                SpotlightReducer()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
                $0.databaseClient.observeFoods = {
                    XCTAssertEqual($0, .name)
                    XCTAssertEqual($1, .forward)
                    return foodStream
                }
                $0.databaseClient.observeMeals = {
                    mealStream
                }
                $0.spotlightClient.indexFoods = {
                    XCTAssertNoDifference($0, foods)
                }
                $0.spotlightClient.indexMeals = {
                    XCTAssertNoDifference($0, [.chimichurri])
                }
            }
        )
        await store.send(.start)
        foodContinuation.yield(foods)
        mealContinuation.yield([.chimichurri])
        foodContinuation.finish()
        mealContinuation.finish()
        await store.finish()
    }

    func testHandleSelectedItem_food() async throws {
        let store = TestStore(
            initialState: SpotlightReducer.State(),
            reducer: {
                SpotlightReducer()
            },
            withDependencies: {
                $0.databaseClient.getFoodId = {
                    XCTAssertEqual($0, Food.chiliPepper.id)
                    return .chiliPepper
                }
            }
        )
        let activity = NSUserActivity(activityType: "test")
        activity.userInfo?[CSSearchableItemActivityIdentifier] = "foodId:\(Food.chiliPepper.id!)"
        await store.send(.handleSelectedItem(activity))
        await store.receive {
            guard case .delegate(.showFoodDetails(.chiliPepper)) = $0 else { return false }
            return true
        }
    }

    func testHandleSelectedItem_meal() async throws {
        let store = TestStore(
            initialState: SpotlightReducer.State(),
            reducer: {
                SpotlightReducer()
            },
            withDependencies: {
                $0.databaseClient.getMealId = {
                    XCTAssertEqual($0, 1)
                    return .chimichurri
                }
            }
        )
        let activity = NSUserActivity(activityType: "test")
        activity.userInfo?[CSSearchableItemActivityIdentifier] = "mealId:\(Meal.chimichurri.id!)"
        await store.send(.handleSelectedItem(activity))
        await store.receive {
            guard case .delegate(.showMealDetails(.chimichurri)) = $0 else { return false }
            return true
        }
    }

    func testSpotlightSearchInApp() async throws {
        let store = TestStore(
            initialState: SpotlightReducer.State(),
            reducer: {
                SpotlightReducer()
            },
            withDependencies: {
                $0.uuid = .constant(.init(0))
            }
        )
        let activity = NSUserActivity(activityType: "test")
        activity.userInfo?[CSSearchQueryString] = "eggplant"
        await store.send(.handleSearchInApp(activity))
        await store.receive {
            guard case .delegate(.searchFood("eggplant")) = $0 else { return false }
            return true
        }
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
            id: 1,
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
