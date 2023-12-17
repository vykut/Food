import Foundation

public extension Energy {
    func formatted<Style: FormatStyle>(
        _ style: Style
    ) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }

    func formatted(
        width: Measurement<UnitEnergy>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitEnergy> = .asProvided
    ) -> String {
        self.formatted(.measurement(
            width: width,
            usage: usage,
            numberFormatStyle: .number.precision(value > 1000 ? .fractionLength(0) : .fractionLength(0...1))
        ))
    }

    func formatted(
        width: Measurement<UnitEnergy>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitEnergy> = .asProvided,
        fractionLength: ClosedRange<Int>
    ) -> String {
        self.formatted(
            width: width,
            usage: usage,
            numberFormatStyle: .number.precision(.fractionLength(fractionLength))
        )
    }

    func formatted(
        width: Measurement<UnitEnergy>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitEnergy> = .asProvided,
        fractionLength: Int
    ) -> String {
        self.formatted(
            width: width,
            usage: usage,
            numberFormatStyle: .number.precision(.fractionLength(fractionLength))
        )
    }

    func formatted(
        width: Measurement<UnitEnergy>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitEnergy> = .asProvided,
        numberFormatStyle: FloatingPointFormatStyle<Double>
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
            numberFormatStyle: numberFormatStyle
        ))
    }
}

extension FormatStyle where Self == EnergyFormat {
    public static func measurement(
        width: Measurement<UnitEnergy>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitEnergy> = .asProvided,
        numberFormatStyle: FloatingPointFormatStyle<Double> = .number.precision(.fractionLength(0...1))
    ) -> Self {
        .init(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle
        )
    }
}
