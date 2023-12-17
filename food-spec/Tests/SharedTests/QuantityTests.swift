import Foundation
import XCTest
@testable import Shared

final class QuantityTests: XCTestCase {
    func testFormatting() async throws {
        var quantity = Quantity(value: 340, unit: .grams)
        var formattedQuantity = quantity.formatted(width: .wide)
        XCTAssertEqual(formattedQuantity, "340 grams")
        quantity = .grams(100.2345143532)
        formattedQuantity = quantity.formatted(width: .abbreviated)
        XCTAssertEqual(formattedQuantity, "100.2 g")
        quantity = .grams(1000.2345143532)
        formattedQuantity = quantity.formatted(width: .abbreviated)
        XCTAssertEqual(formattedQuantity, "1,000 g")
        quantity = .init(value: 300, unit: .milligrams)
        formattedQuantity = quantity.formatted(width: .narrow)
        XCTAssertEqual(formattedQuantity, "300mg")
        quantity = .init(value: 2, unit: .tablespoons)
        formattedQuantity = quantity.formatted(width: .wide)
        XCTAssertEqual(formattedQuantity, "2 tablespoons")
        formattedQuantity = quantity.formatted(width: .abbreviated)
        XCTAssertEqual(formattedQuantity, "2 tbsp")
        formattedQuantity = quantity.formatted(width: .narrow)
        XCTAssertEqual(formattedQuantity, "2tbsp")
        quantity = .init(value: 2.54, unit: .cups)
        formattedQuantity = quantity.formatted(width: .wide)
        XCTAssertEqual(formattedQuantity, "2.5 cups")
        formattedQuantity = quantity.formatted(width: .abbreviated)
        XCTAssertEqual(formattedQuantity, "2.5 c")
        formattedQuantity = quantity.formatted(width: .narrow)
        XCTAssertEqual(formattedQuantity, "2.5c")
        quantity = .init(value: 2, unit: .teaspoons)
        formattedQuantity = quantity.formatted(width: .wide)
        XCTAssertEqual(formattedQuantity, "2 teaspoons")
        formattedQuantity = quantity.formatted(width: .abbreviated)
        XCTAssertEqual(formattedQuantity, "2 tsp")
        formattedQuantity = quantity.formatted(width: .narrow)
        XCTAssertEqual(formattedQuantity, "2tsp")
        quantity = .init(value: 2.25, unit: .cups)
        formattedQuantity = quantity.formatted(width: .wide, fractionLength: 0...2)
        XCTAssertEqual(formattedQuantity, "2.25 cups")
    }

    func testConversion() async throws {
        var energy = Quantity(value: 453.592, unit: .grams)
        var convertedEnergy = energy.converted(to: .pounds)
        XCTAssertEqual(convertedEnergy, .init(value: 1, unit: .pounds))
        energy = Quantity(value: 1, unit: .ounces)
        convertedEnergy = energy.convertedToBaseUnit()
        XCTAssertEqual(convertedEnergy, .init(value: 28.3495, unit: .grams))
    }
}
