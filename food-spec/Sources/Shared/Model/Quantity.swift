import Foundation

public struct Quantity: Codable, Hashable {
    public let value: Double
    public let unit: Unit

    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }

    public var measurement: Measurement<UnitMass> {
        .init(value: value, unit: unit.unit)
    }

    public func converted(to otherUnit: Unit) -> Self {
        .init(
            value: measurement.converted(to: otherUnit.unit).value,
            unit: otherUnit
        )
    }

    public enum Unit: Codable {
        case kilograms
        case grams
        case decigrams
        case centigrams
        case milligrams
        case micrograms
        case nanograms
        case picograms
        case ounces
        case pounds
        case stones
        case metricTons
        case shortTons
        case carats
        case ouncesTroy
        case slugs

        var unit: UnitMass {
            switch self {
                case .kilograms: .kilograms
                case .grams: .grams
                case .decigrams: .decigrams
                case .centigrams: .centigrams
                case .milligrams: .milligrams
                case .micrograms: .micrograms
                case .nanograms: .nanograms
                case .picograms: .picograms
                case .ounces: .ounces
                case .pounds: .pounds
                case .stones: .stones
                case .metricTons: .metricTons
                case .shortTons: .shortTons
                case .carats: .carats
                case .ouncesTroy: .ouncesTroy
                case .slugs: .slugs
            }
        }
    }
}

public extension Quantity {
    static var zero: Self { .zero(unit: .grams) }

    static func zero(unit: Unit) -> Self {
        .init(value: .zero, unit: unit)
    }

    static func grams(_ value: Double) -> Self {
        .init(value: value, unit: .grams)
    }

    static func milligrams(_ value: Double) -> Self {
        .init(value: value, unit: .milligrams)
    }
}


extension Quantity: Comparable {
    public static func < (lhs: Quantity, rhs: Quantity) -> Bool {
        lhs.measurement < rhs.measurement
    }
}

public extension Quantity {
    func formatted<Style: FormatStyle>(
        _ style: Style
    ) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }

    func formatted(
        width: Measurement<UnitMass>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitMass> = .asProvided,
        numberFormatStyle: FloatingPointFormatStyle<Double>? = nil
    ) -> String {
        self.formatted(.measurement(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle
        ))
    }
}

public struct QuantityFormat: FormatStyle {
    let width: Measurement<UnitMass>.FormatStyle.UnitWidth
    let usage: MeasurementFormatUnitUsage<UnitMass>
    let numberFormatStyle: FloatingPointFormatStyle<Double>?

    public func format(_ value: Quantity) -> String {
        value.measurement.formatted(.measurement(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle
        ))
    }
}

extension FormatStyle where Self == QuantityFormat {
    public static func measurement(
        width: Measurement<UnitMass>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitMass> = .general,
        numberFormatStyle: FloatingPointFormatStyle<Double>? = nil
    ) -> Self {
        .init(width: width, usage: usage, numberFormatStyle: numberFormatStyle)
    }
}

extension Quantity {
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            value: (lhs.measurement + rhs.measurement.converted(to: lhs.unit.unit)).value,
            unit: lhs.unit
        )
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
}
