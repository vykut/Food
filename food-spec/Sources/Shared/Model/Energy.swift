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

extension Energy: Comparable {
    public static func < (lhs: Energy, rhs: Energy) -> Bool {
        lhs.measurement < rhs.measurement
    }
}

public extension Energy {
    func formatted<Style: FormatStyle>(
        _ style: Style
    ) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }

    func formatted(
        width: Measurement<UnitEnergy>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitEnergy> = .asProvided,
        numberFormatStyle: FloatingPointFormatStyle<Double> = .number
    ) -> String {
        self.formatted(.measurement(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle
        ))
    }
}

public struct EnergyFormat: FormatStyle {
    let width: Measurement<UnitEnergy>.FormatStyle.UnitWidth
    let usage: MeasurementFormatUnitUsage<UnitEnergy>
    let numberFormatStyle: FloatingPointFormatStyle<Double>

    public func format(_ value: Energy) -> String {
        value.measurement.formatted(.measurement(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle.precision(value.value < 1000 ? .fractionLength(0...1) : .fractionLength(0))
        ))
    }
}

extension FormatStyle where Self == EnergyFormat {
    public static func measurement(
        width: Measurement<UnitEnergy>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitEnergy> = .asProvided,
        numberFormatStyle: FloatingPointFormatStyle<Double> = .number
    ) -> Self {
        .init(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle
        )
    }
}

extension Energy {
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            value: (lhs.measurement + rhs.measurement.converted(to: lhs.unit.unit)).value,
            unit: lhs.unit
        )
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(
            value: (lhs.measurement - rhs.measurement.converted(to: lhs.unit.unit)).value,
            unit: lhs.unit
        )
    }

    public static func * (lhs: Self, rhs: Double) -> Self {
        .init(
            value: lhs.value * rhs,
            unit: lhs.unit
        )
    }

    public static func *= (lhs: inout Self, rhs: Double) {
        lhs = lhs * rhs
    }

    public static func / (lhs: Self, rhs: Double) -> Self {
        .init(
            value: lhs.value / rhs,
            unit: lhs.unit
        )
    }

    public static func /= (lhs: inout Self, rhs: Double) {
        lhs = lhs / rhs
    }
}
