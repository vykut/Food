import Foundation
import XCTest
@testable import API

final class APITests: XCTestCase {
    func testValidServingSize() async throws {
        var food = FoodApiModel(servingSize: 100)
        XCTAssertEqual(hasValidServingSize(food), true)
        food = .init(servingSize: 100.4)
        XCTAssertEqual(hasValidServingSize(food), true)
        food = .init(servingSize: 99.6)
        XCTAssertEqual(hasValidServingSize(food), true)
        food = .init(servingSize: 283.495)
        XCTAssertEqual(hasValidServingSize(food), false)
        food = .init(servingSize: 12)
        XCTAssertEqual(hasValidServingSize(food), false)
        food = .init(servingSize: 0)
        XCTAssertEqual(hasValidServingSize(food), false)
        food = .init(servingSize: -100)
        XCTAssertEqual(hasValidServingSize(food), false)
    }
}

fileprivate extension FoodApiModel {
    init(servingSize: Double) {
        self.init(
            name: "",
            calories: 0,
            servingSizeG: servingSize,
            fatTotalG: 0,
            fatSaturatedG: 0,
            proteinG: 0,
            sodiumMg: 0,
            potassiumMg: 0,
            cholesterolMg: 0,
            carbohydratesTotalG: 0,
            fiberG: 0,
            sugarG: 0
        )
    }
}
