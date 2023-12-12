import SwiftUI
import ComposableArchitecture
import Shared

public struct NutritionalValuePicker: View {
    @Bindable var store: StoreOf<NutritionalValuePickerFeature>

    private let formatter: NumberFormatter = {
        let n = NumberFormatter()
        n.numberStyle = .decimal
        n.maximumFractionDigits = 2
        n.minimum = 0.01
        return n
    }()

    public init(store: StoreOf<NutritionalValuePickerFeature>) {
        self.store = store
    }

    public var body: some View {
        GroupBox {
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
}

#Preview {
    struct PreviewView: View {
        @State var quantity = Quantity(value: 100, unit: .grams)

        var body: some View {
            NutritionalValuePicker(
                store: .init(
                    initialState: NutritionalValuePickerFeature.State(),
                    reducer: {
                        NutritionalValuePickerFeature()
                    }
                )
            )
                .padding()
        }
    }
    return PreviewView()
}
