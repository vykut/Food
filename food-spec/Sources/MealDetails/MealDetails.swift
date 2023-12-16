import SwiftUI
import Shared
import MealForm
import FoodDetails
import FoodComparison
import ComposableArchitecture

public struct MealDetails: View {
    @Bindable var store: StoreOf<MealDetailsFeature>
    let calculator = NutritionalValuesCalculator()

    public init(store: StoreOf<MealDetailsFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            summarySection
            ingredientsSection
            notesSection
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    self.store.send(.editButtonTapped)
                }
            }
        }
        .navigationTitle(self.store.meal.name.capitalized)
        .navigationDestination(
            item: self.$store.scope(state: \.foodDetails, action: \.foodDetails),
            destination: { store in
                FoodDetails(store: store)
            }
        )
        .navigationDestination(
            item: self.$store.scope(state: \.foodComparison, action: \.foodComparison),
            destination: { store in
                FoodComparison(store: store)
            }
        )
        .sheet(
            item: self.$store.scope(state: \.mealForm, action: \.mealForm),
            content: { store in
                NavigationStack {
                    MealForm(store: store)
                }
            }
        )
    }

    private var summarySection: some View {
        Section("Summary") {
            let nutritionFacts = self.calculator.nutritionalValues(for: self.store.meal).foodWithQuantity
            LabeledContent("Energy", value: nutritionFacts.energy, format: .measurement(width: .wide))
            LabeledContent("Protein", value: nutritionFacts.protein, format: .measurement(width: .wide))
            LabeledContent("Carbohydrate", value: nutritionFacts.carbohydrate, format: .measurement(width: .wide))
            LabeledContent("Fat", value: nutritionFacts.fatTotal, format: .measurement(width: .wide))
            LabeledContent("Servings", value: self.store.meal.servings, format: .number)

            ListButton("Nutritional values per serving size") {
                self.store.send(.nutritionalInfoPerServingSizeButtonTapped)
            }
            .disabled(self.store.meal.servings == 1)

            ListButton("Nutritional values per total") {
                self.store.send(.nutritionalInfoButtonTapped)
            }
        }
    }

    private var ingredientsSection: some View {
        Section("^[\(self.store.meal.ingredients.count) Ingredient](inflect: true)") {
            if self.store.meal.ingredients.count > 1 {
                ListButton("Ingredient comparison") {
                    self.store.send(.ingredientComparisonButtonTapped)
                }
            }
            ForEach(self.store.meal.ingredients, id: \.food.id) { ingredient in
                ListButton {
                    self.store.send(.ingredientTapped(ingredient))
                } label: {
                    LabeledListRow(
                        title: "\(ingredient.food.name.capitalized) \(ingredient.quantity.formatted(width: .wide))",
                        footnote: ingredient.foodWithQuantity.nutritionalSummary
                    )
                }
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            Text(self.store.meal.instructions)
        }
    }
}

#Preview {
    NavigationStack {
        MealDetails(
            store: .init(
                initialState: MealDetailsFeature.State(meal: .preview),
                reducer: {
                    MealDetailsFeature()
                }
            )
        )
    }
}
