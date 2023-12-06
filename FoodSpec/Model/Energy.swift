//
//  Energy.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 04/12/2023.
//

import Foundation

struct Energy: Codable, Hashable {
    let value: Double
    let unit: Unit

    var measurement: Measurement<UnitEnergy> {
        .init(value: value, unit: unit.unit)
    }

    func converted(to otherUnit: Unit) -> Self {
        .init(
            value: measurement.converted(to: otherUnit.unit).value,
            unit: otherUnit
        )
    }

    enum Unit: Codable {
        case kilojoules
        case joules
        case kilocalories
        case calories
        case kilowattHours

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

extension Energy: Comparable {
    static func < (lhs: Energy, rhs: Energy) -> Bool {
        lhs.measurement < rhs.measurement
    }
}

extension Energy {
    func formatted<Style: FormatStyle>(
        _ style: Style
    ) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }

    func formatted(
        width: Measurement<UnitEnergy>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitEnergy> = .asProvided,
        numberFormatStyle: FloatingPointFormatStyle<Double>? = nil
    ) -> String {
        self.formatted(.measurement(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle
        ))
    }
}

struct EnergyFormat: FormatStyle {
    let width: Measurement<UnitEnergy>.FormatStyle.UnitWidth
    let usage: MeasurementFormatUnitUsage<UnitEnergy>
    let numberFormatStyle: FloatingPointFormatStyle<Double>?

    func format(_ value: Energy) -> String {
        value.measurement.formatted(.measurement(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle
        ))
    }
}

extension FormatStyle where Self == EnergyFormat {
    static func measurement(
        width: Measurement<UnitEnergy>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitEnergy> = .general,
        numberFormatStyle: FloatingPointFormatStyle<Double>? = nil
    ) -> Self {
        .init(width: width, usage: usage, numberFormatStyle: numberFormatStyle)
    }
}
