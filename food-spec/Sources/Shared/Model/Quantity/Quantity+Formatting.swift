import Foundation

public extension Quantity {
    func formatted<Style: FormatStyle>(
        _ style: Style
    ) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }

    func formatted(
        width: Measurement<UnitMass>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitMass> = .asProvided
    ) -> String {
        self.formatted(.measurement(
            width: width,
            usage: usage,
            numberFormatStyle: .number.precision(value > 1000 ? .fractionLength(0) : .fractionLength(0...1))
        ))
    }

    func formatted(
        width: Measurement<UnitMass>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitMass> = .asProvided,
        fractionLength: ClosedRange<Int>
    ) -> String {
        self.formatted(
            width: width,
            usage: usage,
            numberFormatStyle: .number.precision(.fractionLength(fractionLength))
        )
    }

    func formatted(
        width: Measurement<UnitMass>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitMass> = .asProvided,
        fractionLength: Int
    ) -> String {
        self.formatted(
            width: width,
            usage: usage,
            numberFormatStyle: .number.precision(.fractionLength(fractionLength))
        )
    }

    func formatted(
        width: Measurement<UnitMass>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitMass> = .asProvided,
        numberFormatStyle: FloatingPointFormatStyle<Double>
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
        return switch value.unit {
            case .cups:
                Measurement<UnitVolume>(value: value.value, unit: .cups)
                    .formatted(volumeMeasurement(numberFormatStyle: self.numberFormatStyle))
            case .tablespoons:
                Measurement<UnitVolume>(value: value.value, unit: .tablespoons)
                    .formatted(volumeMeasurement(numberFormatStyle: self.numberFormatStyle))
            case .teaspoons:
                Measurement<UnitVolume>(value: value.value, unit: .teaspoons)
                    .formatted(volumeMeasurement(numberFormatStyle: self.numberFormatStyle))
            default:
                value.measurement.formatted(.measurement(
                    width: width,
                    usage: usage,
                    numberFormatStyle: self.numberFormatStyle
                ))
        }
    }
}

extension FormatStyle where Self == QuantityFormat {
    public static func measurement(
        width: Measurement<UnitMass>.FormatStyle.UnitWidth,
        usage: MeasurementFormatUnitUsage<UnitMass> = .asProvided,
        numberFormatStyle: FloatingPointFormatStyle<Double> = .number.precision(.fractionLength(0...1))
    ) -> Self {
        .init(
            width: width,
            usage: usage,
            numberFormatStyle: numberFormatStyle
        )
    }
}
