import Foundation

public struct Quantity: Codable, Hashable, Sendable {
    public var value: Double
    public var unit: Unit

    public init(value: Double, unit: Unit = .baseUnit) {
        self.value = value
        self.unit = unit
    }

    public var measurement: Measurement<UnitMass> {
        .init(value: value, unit: unit.unit)
    }

    public func convertedToBaseUnit() -> Self {
        converted(to: .baseUnit)
    }

    public func converted(to otherUnit: Unit) -> Self {
        guard unit != otherUnit else { return self }
        return .init(
            value: measurement.converted(to: otherUnit.unit).value,
            unit: otherUnit
        )
    }

    public static var baseUnit: Unit { .baseUnit }

    public enum Unit: String, Codable, Hashable, Sendable {
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
        case metricTons = "metric tons"
        case shortTons = "short tons"
        case carats
        case ouncesTroy = "troy ounces"
        case slugs
        case cups
        case teaspoons
        case tablespoons

        public static var baseUnit: Unit { .grams }

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
                case .cups: .cups
                case .teaspoons: .teaspoons
                case .tablespoons: .tablespoons
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
        numberFormatStyle: FloatingPointFormatStyle<Double> = .number
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
    let numberFormatStyle: FloatingPointFormatStyle<Double>

    private var volumeWidth: Measurement<UnitVolume>.FormatStyle.UnitWidth {
        switch width {
            case .wide: .wide
            case .abbreviated: .abbreviated
            case .narrow: .narrow
            default: .abbreviated
        }
    }

    private var volumeUsage: MeasurementFormatUnitUsage<UnitVolume> {
        switch usage {
            case .general: .general
            case .asProvided: .asProvided
            default: .general
        }
    }

    private func volumeMeasurement(numberFormatStyle: FloatingPointFormatStyle<Double>) -> Measurement<UnitVolume>.FormatStyle {
        .measurement(
            width: volumeWidth,
            usage: volumeUsage,
            numberFormatStyle: numberFormatStyle
        )
    }

    public func format(_ value: Quantity) -> String {
        let numberFormatStyle = self.numberFormatStyle.precision(value.value < 1000 ? .fractionLength(0...1) : .fractionLength(0))
        return switch value.unit {
            case .cups:
                Measurement<UnitVolume>(value: value.value, unit: .cups)
                    .formatted(volumeMeasurement(numberFormatStyle: numberFormatStyle))
            case .tablespoons:
                Measurement<UnitVolume>(value: value.value, unit: .tablespoons)
                    .formatted(volumeMeasurement(numberFormatStyle: numberFormatStyle))
            case .teaspoons:
                Measurement<UnitVolume>(value: value.value, unit: .teaspoons)
                    .formatted(volumeMeasurement(numberFormatStyle: numberFormatStyle))
            default:
                value.measurement.formatted(.measurement(
                    width: width,
                    usage: usage,
                    numberFormatStyle: numberFormatStyle
                ))
        }
    }
}

extension FormatStyle where Self == QuantityFormat {
    public static func measurement(
        width: Measurement<UnitMass>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitMass> = .asProvided,
        numberFormatStyle: FloatingPointFormatStyle<Double> = .number
    ) -> Self {
        .init(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle.precision(.fractionLength(0...1))
        )
    }
}

extension Quantity {
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
}

extension UnitMass {
    static let cups: UnitMass = .init(symbol: "c", converter: UnitConverterLinear(coefficient: 0.236588236485))
    static let teaspoons: UnitMass = .init(symbol: "tsp", converter: UnitConverterLinear(coefficient: 0.004928921594))
    static let tablespoons: UnitMass = .init(symbol: "tbsp", converter: UnitConverterLinear(coefficient: 0.014786764782))
}
