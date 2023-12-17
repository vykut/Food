import Foundation
import XCTest
@testable import Shared

final class NutritionalValuesCalculatorTests: XCTestCase {
    func testNutritionalValues() async throws {
        let calculator = NutritionalValuesCalculator.liveValue
        let meal = Meal.chimichurri
        let nutritionalValues = calculator.nutritionalValues(meal: meal)
        XCTAssertEqual(
            nutritionalValues,
            .init(
                food: .init(
                    name: "Chimichurri",
                    energy: .kcal(315.8857846731901),
                    fatTotal: .grams(29.340329289305906),
                    fatSaturated: .grams(3.7919126636543408),
                    protein: .grams(4.3893909106024305),
                    sodium: .grams(0.0248711758044329),
                    potassium: .grams(0.12484168203297843),
                    cholesterol: .zero,
                    carbohydrate: .grams(18.78544223433158),
                    fiber: .grams(10.338990134468709),
                    sugar: .grams(0.86095509195355)
                ),
                quantity: .grams(474.59804111025)
            )
        )
    }

    func testNutritionalValuesPerServingSize() async throws {
        let calculator = NutritionalValuesCalculator.liveValue
        let meal = Meal.chimichurri
        let nutritionalValues = calculator.nutritionalValuesPerServing(meal: meal)
        XCTAssertEqual(
            nutritionalValues,
            .init(
                food: .init(
                    name: "Chimichurri",
                    energy: .kcal(315.88578467319),
                    fatTotal: .grams(29.3403292893059),
                    fatSaturated: .grams(3.79191266365434),
                    protein: .grams(4.389390910602431),
                    sodium: .grams(0.024871175804432894),
                    potassium: .grams(0.12484168203297842),
                    cholesterol: .zero,
                    carbohydrate: .grams(18.78544223433158),
                    fiber: .grams(10.33899013446871),
                    sugar: .grams(0.86095509195355)
                ),
                quantity: .grams(47.459804111025)
            )
        )
    }
}

fileprivate extension Meal {
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

    static var coriander: Self {
        .init(
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
