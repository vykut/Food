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

    enum Unit: Codable {
        case kilojoules
        case joules
        case kilocalories
        case calories
        case kilowattHours

        var unit: UnitEnergy {
            switch self {
                case .kilojoules: return .kilojoules
                case .joules: return .joules
                case .kilocalories: return .kilocalories
                case .calories: return .calories
                case .kilowattHours: return .kilowattHours
            }
        }
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
