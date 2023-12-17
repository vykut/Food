import Foundation

public struct Energy: Codable, Hashable, Sendable {
    public var value: Double
    public var unit: Unit

    public init(value: Double, unit: Unit = .baseUnit) {
        self.value = value
        self.unit = unit
    }

    public var measurement: Measurement<UnitEnergy> {
        .init(value: value, unit: unit.unit)
    }

    public func convertedToBaseUnit() -> Self {
        converted(to: .baseUnit)
    }

    public mutating func convert(to otherUnit: Unit) {
        self = converted(to: otherUnit)
    }

    public func converted(to otherUnit: Unit) -> Self {
        guard unit != otherUnit else { return self }
        return .init(
            value: measurement.converted(to: otherUnit.unit).value,
            unit: otherUnit
        )
    }

    public static var baseUnit: Unit { .baseUnit }

    public enum Unit: Codable, Sendable {
        case kilojoules
        case joules
        case kilocalories
        case calories
        case kilowattHours

        public static var baseUnit: Unit { .kilocalories }

        var unit: UnitEnergy {
            switch self {
                case .kilojoules: .kilojoules
                case .joules: .joules
                case .kilocalories: .kilocalories
                case .calories: .calories
                case .kilowattHours: .kilowattHours
            }
        }
    }
}

public extension Energy {
    static var zero: Self { .init(value: 0, unit: baseUnit) }

    static func kcal(_ value: Double) -> Self {
        .init(value: value, unit: .kilocalories)
    }
}
