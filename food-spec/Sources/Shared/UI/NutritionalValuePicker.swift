import SwiftUI

public struct NutritionalValuePicker: View {
    @Binding var quantity: Quantity
    var options: [Quantity.Unit] = [.grams, .ounces, .cups, .tablespoons, .teaspoons]

    private let formatter: NumberFormatter = {
        let n = NumberFormatter()
        n.numberStyle = .decimal
        return n
    }()

    private var pickerBinding: Binding<Quantity.Unit> {
        .init(
            get: {
                quantity.unit
            },
            set: { unit in
                let count: Double = if unit == .grams { 100 } else { 1 }
                self.quantity = Quantity(value: count, unit: unit)
            }
        )
    }

    public var body: some View {
        GroupBox {
            DisclosureGroup {
                VStack {
                    LabeledContent("Value") {
                        HStack {
                            TextField("Value", value: $quantity.value, formatter: NumberFormatter())
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            Stepper("Value", value: $quantity.value)
                                .labelsHidden()
                        }
                    }
                    LabeledContent("Unit") {
                        Picker("Unit", selection: pickerBinding) {
                            ForEach(options, id: \.self) { unit in
                                Text(unit.rawValue.capitalized)
                                    .tag(unit)
                            }
                        }
                    }
                }
                .padding(.top)

            } label: {
                Text(
                    "Nutritional values per \(quantity.formatted(width: .wide))"
                )
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
            NutritionalValuePicker(quantity: $quantity)
                .padding()
        }
    }
    return PreviewView()
}
