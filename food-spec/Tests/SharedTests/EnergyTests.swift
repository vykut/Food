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
    }
}
