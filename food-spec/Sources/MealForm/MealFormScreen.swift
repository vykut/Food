import SwiftUI
import Shared
import QuantityPicker
import AddIngredients
import ComposableArchitecture

public struct MealFormScreen: View {
    @Bindable var store: StoreOf<MealForm>
    @FocusState var focusedField: String?

    public init(store: StoreOf<MealForm>) {
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
                AddIngredientsScreen(store: store)
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
        Section("^[\(self.store.meal.ingredients.count) Ingredient](inflect: true)") {
            Button("Add ingredients") {
                self.store.send(.addIngredientsButtonTapped, animation: .default)
                focusedField = nil
            }

            ForEach(self.store.shownIngredients, id: \.food.id) { ingredient in
                ListButton {
                    self.store.send(.ingredientTapped(ingredient))
                } label: {
                    LabeledListRow(
                        title: ingredient.food.name.capitalized,
                        footnote: ingredient.quantity.formatted(width: .wide, fractionLength: 0...2)
                    )
                }
            }
            .onDelete { offsets in
                self.store.send(.onDeleteIngredients(offsets))
            }
            .animation(.default, value: self.store.shownIngredients)

            if self.store.shouldShowShowAllIngredientsButton {
                Button("Show all") {
                    self.store.send(.showAllIngredientsButtonTapped)
                }
            }
        }
    }

    private let formatter: NumberFormatter = {
        let n = NumberFormatter()
        n.numberStyle = .decimal
        n.maximumFractionDigits = 1
        n.maximumIntegerDigits = 2
        return n
    }()

    private var servingSizeSection: some View {
        Section("Servings") {
            Stepper(self.store.meal.servings.formatted(.number.precision(.fractionLength(0...1)))) {
                self.store.send(.servingsIncrementButtonTapped)
            } onDecrement: {
                self.store.send(.servingsDecrementButtonTapped)
            }
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
        MealFormScreen(
            store: .init(
                initialState: MealForm.State(
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
                        servings: 3,
                        instructions: "instructions"
                    )
                ),
                reducer: {
                    MealForm()
                }
            )
        )
    }
}
