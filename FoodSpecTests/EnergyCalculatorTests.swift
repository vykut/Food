//
//  EnergyCalculatorTests.swift
//  FoodSpecTests
//
//  Created by Victor Socaciu on 08/12/2023.
//

import XCTest
import ComposableArchitecture
@testable import FoodSpec

final class EnergyCalculatorTests: XCTestCase {
    func testCalculate() async throws {
        let food = Food(
            name: "eggplant",
            energy: .zero,
            fatTotal: .init(value: 0.2, unit: .grams),
            fatSaturated: .zero,
            protein: .init(value: 0.8, unit: .grams),
            sodium: .zero,
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .init(value: 8.7, unit: .grams),
            fiber: .zero,
            sugar: .zero
        )
        let energyCalculator = EnergyCalculator()
        let breakdown = energyCalculator.calculateEnergy(for: food)
        XCTAssertNoDifference(
            breakdown,
            .init(
                protein: .kcal(3.2),
                carbohydrate: .kcal(34.8),
                fat: .kcal(1.8)
            )
        )
    }

    func testCalculate_differentUnits() async throws {
        let food = Food(
            name: "eggplant",
            energy: .zero,
            fatTotal: .init(value: 100, unit: .milligrams),
            fatSaturated: .zero,
            protein: .init(value: 0.1, unit: .kilograms),
            sodium: .zero,
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .init(value: 1, unit: .ounces),
            fiber: .zero,
            sugar: .zero
        )
        let energyCalculator = EnergyCalculator()
        let breakdown = energyCalculator.calculateEnergy(for: food)
        XCTAssertEqual(breakdown.protein.value, 400, accuracy: 0.01)
        XCTAssertEqual(breakdown.carbohydrate.value, 114, accuracy: 1)
        XCTAssertEqual(breakdown.fat.value, 0.9, accuracy: 0.01)
    }

    func testBreakdown_computedProperties() async throws {
        let food = Food(
            name: "eggplant",
            energy: .zero,
            fatTotal: .init(value: 0.2, unit: .grams),
            fatSaturated: .zero,
            protein: .init(value: 0.8, unit: .grams),
            sodium: .zero,
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .init(value: 8.7, unit: .grams),
            fiber: .zero,
            sugar: .zero
        )
        let energyCalculator = EnergyCalculator()
        let breakdown = energyCalculator.calculateEnergy(for: food)
        XCTAssertEqual(breakdown.total, .kcal(39.8))
        XCTAssertEqual(breakdown.proteinRatio, 3.2 / 39.8)
        XCTAssertEqual(breakdown.carbohydrateRatio, 34.8 / 39.8)
        XCTAssertEqual(breakdown.fatRatio, 1.8 / 39.8)
    }
}
