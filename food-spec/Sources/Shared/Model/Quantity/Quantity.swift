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
    static var zero: Self { .zero(unit: baseUnit) }

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

extension UnitMass {
    static let cups: UnitMass = .init(symbol: "c", converter: UnitConverterLinear(coefficient: 0.236588236485))
    static let teaspoons: UnitMass = .init(symbol: "tsp", converter: UnitConverterLinear(coefficient: 0.004928921594))
    static let tablespoons: UnitMass = .init(symbol: "tbsp", converter: UnitConverterLinear(coefficient: 0.014786764782))
}
