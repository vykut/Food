import Foundation
import ComposableArchitecture
import Shared
import XCTest
@testable import FoodDetails

@MainActor
final class FoodDetailsTests: XCTestCase {
    func testIntegration_withQuantityPicker() async throws {
        let food = Food.preview
        let store = TestStore(
            initialState: FoodDetails.State(food: food),
            reducer: {
                FoodDetails()
            }
        )
        await store.send(.quantityPicker(.updateValue(200))) {
            $0.quantityPicker.quantity = .grams(200)
            $0.food = Food(
                id: food.id,
                name: food.name,
                energy: food.energy * 2,
                fatTotal: food.fatTotal * 2,
                fatSaturated: food.fatSaturated * 2,
                protein: food.protein * 2,
                sodium: food.sodium * 2,
                potassium: food.potassium * 2,
                cholesterol: food.cholesterol * 2,
                carbohydrate: food.carbohydrate * 2,
                fiber: food.fiber * 2,
                sugar: food.sugar * 2
            )
        }
    }
}
