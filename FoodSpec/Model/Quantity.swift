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

    func converted(to otherUnit: Unit) -> Self {
        .init(
            value: measurement.converted(to: otherUnit.unit).value,
            unit: otherUnit
        )
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
