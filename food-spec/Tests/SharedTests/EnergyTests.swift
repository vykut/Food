import Foundation
import XCTest
@testable import Shared

final class EnergyTests: XCTestCase {
    func testFormatting() async throws {
        var energy = Energy(value: 340, unit: .kilocalories)
        var formattedEnergy = energy.formatted(width: .wide)
        XCTAssertEqual(formattedEnergy, "340 kilocalories")
        energy = .kcal(100.2345143532)
        formattedEnergy = energy.formatted(width: .abbreviated)
        XCTAssertEqual(formattedEnergy, "100.2 kcal")
        energy = .init(value: 300, unit: .kilojoules)
        formattedEnergy = energy.formatted(width: .narrow)
        XCTAssertEqual(formattedEnergy, "300kJ")
        energy = .init(value: 3000.43, unit: .kilojoules)
        formattedEnergy = energy.formatted(width: .narrow)
        XCTAssertEqual(formattedEnergy, "3,000kJ")
        energy = .kcal(23.45)
        formattedEnergy = energy.formatted(width: .wide, fractionLength: 0...2)
        XCTAssertEqual(formattedEnergy, "23.45 kilocalories")
    }

    func testConversion() async throws {
        var energy = Energy(value: 340, unit: .kilocalories)
        var convertedEnergy = energy.converted(to: .calories)
        XCTAssertEqual(convertedEnergy, .init(value: 340_000, unit: .calories))
        energy = Energy(value: 418.4, unit: .kilojoules)
        convertedEnergy = energy.convertedToBaseUnit()
        XCTAssertEqual(convertedEnergy, .init(value: 100, unit: .kilocalories))
    }
}
