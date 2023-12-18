import SwiftUI
import ComposableArchitecture
import Shared

public struct QuantityPickerView: View {
    @Bindable var store: StoreOf<QuantityPicker>
    @Environment(\.quantityPickerStyle) var quantityPickerStyle
    @Environment(\.focusState) var focusState

    private let formatter: NumberFormatter = {
        let n = NumberFormatter()
        n.numberStyle = .decimal
        n.maximumFractionDigits = 2
        n.minimum = 0.01
        return n
    }()

    public init(store: StoreOf<QuantityPicker>) {
        self.store = store
    }

    public var body: some View {
        Group {
            switch quantityPickerStyle {
                case .default:
                    quantityPicker
                case .dropdown:
                    quantityPickerWithDropdown
                case .dropdownGrouped:
                    quantityPickerWithDropdownGrouped
            }
        }
        .tint(.primary)
    }

    private var quantityPickerWithDropdownGrouped: some View {
        GroupBox {
            quantityPickerWithDropdown
        }
    }

    private var quantityPickerWithDropdown: some View {
        DisclosureGroup {
            quantityPicker
                .padding(.top)
        } label: {
            ViewThatFits {
                Text(
                    "Nutritional values per \(store.quantity.formatted(width: .wide))"
                )
                Text(
                    "Nutritional values per \(store.quantity.formatted(width: .abbreviated))"
                )
            }
            .font(.title2)
            .lineLimit(1)
        }
    }

    private var quantityPicker: some View {
        VStack {
            LabeledContent("Value") {
                HStack {
                    TextField("Value", value: $store.quantity.value.sending(\.updateValue), formatter: formatter)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .focused(focusState, equals: "quantity_\(self.store.id ?? 0)")
                    Stepper("Value") {
                        store.send(.incrementButtonTapped)
                    } onDecrement: {
                        store.send(.decrementButtonTapped)
                    }
                    .labelsHidden()

                }
            }
            LabeledContent("Unit") {
                Picker("Unit", selection: $store.quantity.unit.sending(\.updateUnit)) {
                    ForEach(store.options, id: \.self) { unit in
                        Text(unit.rawValue.capitalized)
                            .tag(unit)
                    }
                }
                .labelsHidden()
            }
        }
    }
}

#Preview {
    QuantityPickerView(
        store: .init(
            initialState: QuantityPicker.State(id: nil),
            reducer: {
                QuantityPicker()
            }
        )
    )
    .padding()
}
