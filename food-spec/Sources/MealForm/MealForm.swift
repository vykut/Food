import SwiftUI
import Shared
import QuantityPicker
import ComposableArchitecture

public struct MealForm: View {
    @Bindable var store: StoreOf<MealFormFeature>

    public init(store: StoreOf<MealFormFeature>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $store.meal.sending(\.updateMeal).name)
            }

            Section("Ingredients") {
                List(store.meal.ingredients, id: \.food) { ingredient in
                    VStack(alignment: .leading) {
                        Text(ingredient.food.name)
                        Text(ingredient.quantity.formatted(width: .wide))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Serving size") {
                QuantityPicker(
                    store: store.scope(state: \.quantity, action: \.quantityPicker)
                )
            }

            Section("Notes / Instructions") {
                TextEditor(
                    text: $store.meal.sending(\.updateMeal).instructions
                )
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {

                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {

                }
                .disabled(true)
            }
        }
        .navigationTitle("New Meal")
    }
}

#Preview {
    MealForm(
        store: .init(
            initialState: MealFormFeature.State(),
            reducer: {
                MealFormFeature()
            }
        )
    )
}
