import SwiftUI
import Shared
import QuantityPicker
import ComposableArchitecture

public struct MealForm: View {
    @Bindable var store: StoreOf<MealFormFeature>
    @FocusState var focusedField: String?

    public init(store: StoreOf<MealFormFeature>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $store.meal.sending(\.updateMeal).name)
                    .submitLabel(.done)
                    .focused($focusedField, equals: "name")
            }

            Section("Ingredients") {
                ForEach(store.meal.ingredients, id: \.food) { ingredient in
                    VStack(alignment: .leading) {
                        Text(ingredient.food.name)
                        Text(ingredient.quantity.formatted(width: .wide))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { offsets in
                    self.store.send(.onDeleteIngredients(offsets))
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
                .focused($focusedField, equals: "instructions")
                .frame(minHeight: 100)
            }
        }
        .formStyle(.grouped)
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    self.store.send(.cancelButtonTapped)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    self.store.send(.saveButtonTapped)
                }
                .disabled(self.store.isSaveButtonDisabled)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    self.focusedField = nil
                }
            }
        }
        .navigationTitle("New Meal")
    }
}

#Preview {
    NavigationStack {
        MealForm(
            store: .init(
                initialState: MealFormFeature.State(
                    meal: .init(
                        name: "name",
                        ingredients: [
                            .init(
                                food: .preview(id: 1),
                                quantity: .grams(100)
                            ),
                            .init(
                                food: .preview(id: 2),
                                quantity: .grams(150)
                            ),
                            .init(
                                food: .preview(id: 3),
                                quantity: .grams(230)
                            ),
                        ],
                        servingSize: .grams(250),
                        instructions: "instructions"
                    )
                ),
                reducer: {
                    MealFormFeature()
                }
            )
        )
    }
}
