import Foundation

extension Quantity: Comparable {
    public static func < (lhs: Quantity, rhs: Quantity) -> Bool {
        lhs.measurement < rhs.measurement
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
