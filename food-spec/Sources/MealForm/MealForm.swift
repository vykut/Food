import SwiftUI
import Shared
import QuantityPicker
import AddIngredients
import ComposableArchitecture

public struct MealForm: View {
    @Bindable var store: StoreOf<MealFormFeature>
    @FocusState var focusedField: String?

    public init(store: StoreOf<MealFormFeature>) {
        self.store = store
    }

    public var body: some View {
        Form {
            nameSection
            ingredientsSection
            servingSizeSection
            notesSection
        }
        .formStyle(.grouped)
        .scrollDismissesKeyboard(.immediately)
        .environment(\.focusState, $focusedField)
        .toolbar { toolbar }
        .navigationTitle(self.store.isEdit ? "Edit Meal" : "New Meal")
        .navigationDestination(
            item: self.$store.scope(state: \.addIngredients, action: \.addIngredients),
            destination: { store in
                AddIngredients(store: store)
            }
        )
    }

    private var nameSection: some View {
        Section("Name") {
            TextField("Name", text: self.$store.meal.sending(\.updateMeal).name)
                .submitLabel(.done)
                .focused($focusedField, equals: "name")
        }
    }

    private var ingredientsSection: some View {
        Section("Ingredients") {
            Button("Add ingredient") {
                self.store.send(.addIngredientButtonTapped)
                focusedField = nil
            }
            ForEach(self.store.shownIngredients, id: \.food) { ingredient in
                VStack(alignment: .leading) {
                    Text(ingredient.food.name.capitalized)
                    Text(ingredient.quantity.formatted(width: .wide))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete { offsets in
                self.store.send(.onDeleteIngredients(offsets))
            }
            if self.store.shouldShowShowAllIngredientsButton {
                Button("Show all") {
                    self.store.send(.showAllIngredientsButtonTapped)
                }
            }
        }
    }

    private var servingSizeSection: some View {
        Section("Serving size") {
            QuantityPicker(
                store: self.store.scope(state: \.quantity, action: \.quantityPicker)
            )
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextEditor(
                text: self.$store.meal.sending(\.updateMeal).instructions
            )
            .focused(self.$focusedField, equals: "notes")
            .frame(minHeight: 100)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
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
