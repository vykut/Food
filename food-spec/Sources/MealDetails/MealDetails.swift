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
            Section("Summary") {
                let nutritionFacts = self.store.meal.nutritionalValues
                LabeledContent("Energy", value: nutritionFacts.food.energy, format: .measurement(width: .wide))
                LabeledContent("Protein", value: nutritionFacts.food.protein, format: .measurement(width: .wide))
                LabeledContent("Carbohydrate", value: nutritionFacts.food.protein, format: .measurement(width: .wide))
                LabeledContent("Fat", value: nutritionFacts.food.protein, format: .measurement(width: .wide))
                LabeledContent("Serving Size", value: self.store.meal.servingSize, format: .measurement(width: .wide))

                ListButton("Nutritional values per serving size") {
                    self.store.send(.nutritionalInfoPerServingSizeButtonTapped)
                }
            }

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

            Section("Notes") {
                Text(self.store.meal.instructions)
            }
        }
        .foregroundStyle(.primary)
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
