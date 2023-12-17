import SwiftUI
import Shared
import MealForm
import FoodDetails
import FoodComparison
import ComposableArchitecture

public struct MealDetails: View {
    @Bindable var store: StoreOf<MealDetailsFeature>

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
            item: self.$store.scope(state: \.destination?.foodDetails, action: \.destination.foodDetails),
            destination: { store in
                FoodDetails(store: store)
            }
        )
        .navigationDestination(
            item: self.$store.scope(state: \.destination?.foodComparison, action: \.destination.foodComparison),
            destination: { store in
                FoodComparison(store: store)
            }
        )
        .sheet(
            item: self.$store.scope(state: \.destination?.mealForm, action: \.destination.mealForm),
            content: { store in
                NavigationStack {
                    MealForm(store: store)
                }
            }
        )
    }

    private var summarySection: some View {
        Section("Summary") {
            let nutritionFacts = self.store.nutritionalValuesPerTotal.foodWithQuantity
            LabeledContent("Energy", value: nutritionFacts.energy.formatted(width: .wide))
            LabeledContent("Protein", value: nutritionFacts.protein.formatted(width: .wide))
            LabeledContent("Carbohydrate", value: nutritionFacts.carbohydrate.formatted(width: .wide))
            LabeledContent("Fat", value: nutritionFacts.fatTotal.formatted(width: .wide))
            LabeledContent("Servings", value: self.store.meal.servings, format: .number)

            ListButton("Nutritional values per serving") {
                self.store.send(.nutritionalInfoPerServingButtonTapped)
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
                        title: "\(ingredient.food.name.capitalized) \(ingredient.quantity.formatted(width: .wide, fractionLength: 0...2))",
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
