import SwiftUI

public enum QuantityPickerStyle: Hashable, EnvironmentKey {
    case `default`
    case dropdown
    case dropdownGrouped

    public static var defaultValue: Self { .default }
}

extension EnvironmentValues {
    public var quantityPickerStyle: QuantityPickerStyle {
        get { self[QuantityPickerStyle.self] }
        set { self[QuantityPickerStyle.self] = newValue }
    }
}

extension View {
    public func quantityPickerStyle(_ style: QuantityPickerStyle) -> some View {
        self
            .environment(\.quantityPickerStyle, style)
    }
}
