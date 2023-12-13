import SwiftUI
import ComposableArchitecture
import Shared

public struct QuantityPicker: View {
    @Bindable var store: StoreOf<QuantityPickerFeature>

    private let formatter: NumberFormatter = {
        let n = NumberFormatter()
        n.numberStyle = .decimal
        n.maximumFractionDigits = 2
        n.minimum = 0.01
        return n
    }()

    public init(store: StoreOf<QuantityPickerFeature>) {
        self.store = store
    }

    public var body: some View {
            DisclosureGroup {
                VStack {
                    LabeledContent("Value") {
                        HStack {
                            TextField("Value", value: $store.quantity.value.sending(\.updateValue), formatter: formatter)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
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
                    }
                }
                .font(nil)
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
                .lineLimit(1)
            }
            .tint(.primary)
    }
}

#Preview {
    struct PreviewView: View {
        @State var quantity = Quantity(value: 100, unit: .grams)

        var body: some View {
            QuantityPicker(
                store: .init(
                    initialState: QuantityPickerFeature.State(),
                    reducer: {
                        QuantityPickerFeature()
                    }
                )
            )
                .padding()
        }
    }
    return PreviewView()
}
