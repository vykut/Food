import SwiftUI
import Shared
import QuantityPicker
import ComposableArchitecture

public struct IngredientPicker: View {
    @Bindable var store: StoreOf<IngredientPickerFeature>
    @State private var isDisclosed = false

    public init(store: StoreOf<IngredientPickerFeature>) {
        self.store = store
    }

    public var body: some View {
        DisclosureGroup(
            isExpanded: self.$store.isSelected.sending(\.updateSelection)
        ) {
            QuantityPicker(
                store: self.store.scope(
                    state: \.quantityPicker,
                    action: \.quantityPicker
                )
            )
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(self.store.food.name.capitalized)
                Text(self.store.ingredient.foodWithQuantity.nutritionalSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .disclosureGroupStyle(.selection)
    }
}

#Preview {
    ScrollView {
        ForEach(0..<5) { _ in
            IngredientPicker(
                store: .init(
                    initialState: IngredientPickerFeature.State(food: .preview),
                    reducer: {
                        IngredientPickerFeature()
                    }
                )
            )
            .padding(.horizontal)
        }
    }
}

struct SelectionDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    configuration.label
                    Spacer()
                    if configuration.isExpanded {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.selection)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 8, topTrailing: 8)))
                .onTapGesture {
                    configuration.$isExpanded.animation().wrappedValue.toggle()
                }
                configuration.content
                    .padding(.top)
                    .frame(height: configuration.isExpanded ? nil : 0)
                    .clipped()
                    .allowsHitTesting(configuration.isExpanded ? true : false)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    configuration.isExpanded ? AnyShapeStyle(.selection) : AnyShapeStyle(.clear),
                    lineWidth: 2
                )
        }
    }
}

extension DisclosureGroupStyle where Self == SelectionDisclosureGroupStyle {
    static var selection: Self { .init() }
}
