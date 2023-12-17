import Foundation
import XCTest
@testable import Shared

final class FoodTests: XCTestCase {
    func testChangingServingSize() {
        var food = Food.chiliPepper
        food = food.changingServingSize(to: .grams(200))
        XCTAssertEqual(
            food,
            .init(
                name: "chili pepper",
                energy: .kcal(78.8),
                fatTotal: .grams(0.8),
                fatSaturated: .zero,
                protein: .grams(3.8),
                sodium: .grams(0.016),
                potassium: .grams(0.086),
                cholesterol: .zero,
                carbohydrate: .grams(17.6),
                fiber: .grams(3),
                sugar: .grams(10.6)
            )
        )
    }

    func testNutritionalSummary() {
        let food = Food.chiliPepper
        let nutritionalSummary = food.nutritionalSummary
        XCTAssertEqual(
            nutritionalSummary,
            "39.4kcal | P: 1.9g | C: 8.8g | F: 0.4g"
        )
    }
}

fileprivate extension Food {
    static var chiliPepper: Self {
        .init(
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
}
