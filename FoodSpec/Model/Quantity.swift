//
//  Quantity.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 02/12/2023.
//

import Foundation

struct Quantity: Codable, Hashable {
    let value: Double
    let unit: Unit

    var measurement: Measurement<UnitMass> {
        .init(value: value, unit: unit.unit)
    }

    enum Unit: Codable {
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
                case .kilograms: return .kilograms
                case .grams: return .grams
                case .decigrams: return .decigrams
                case .centigrams: return .centigrams
                case .milligrams: return .milligrams
                case .micrograms: return .micrograms
                case .nanograms: return .nanograms
                case .picograms: return .picograms
                case .ounces: return .ounces
                case .pounds: return .pounds
                case .stones: return .stones
                case .metricTons: return .metricTons
                case .shortTons: return .shortTons
                case .carats: return .carats
                case .ouncesTroy: return .ouncesTroy
                case .slugs: return .slugs
            }
        }
    }
}

extension Quantity: Comparable {
    static func < (lhs: Quantity, rhs: Quantity) -> Bool {
        lhs.measurement < rhs.measurement
    }
}

extension Quantity {
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

struct QuantityFormat: FormatStyle {
    let width: Measurement<UnitMass>.FormatStyle.UnitWidth
    let usage: MeasurementFormatUnitUsage<UnitMass>
    let numberFormatStyle: FloatingPointFormatStyle<Double>?

    func format(_ value: Quantity) -> String {
        value.measurement.formatted(.measurement(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle
        ))
    }
}

extension FormatStyle where Self == QuantityFormat {
    static func measurement(
        width: Measurement<UnitMass>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitMass> = .general,
        numberFormatStyle: FloatingPointFormatStyle<Double>? = nil
    ) -> Self {
        .init(width: width, usage: usage, numberFormatStyle: numberFormatStyle)
    }
}
