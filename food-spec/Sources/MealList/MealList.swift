import SwiftUI
import Shared
import MealForm
import MealDetails
import ComposableArchitecture

public struct MealList: View {
    @Bindable var store: StoreOf<MealListFeature>
    let calculator = NutritionalValuesCalculator()

    public init(store: StoreOf<MealListFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            if !store.meals.isEmpty {
                mealsSection
            } else {
                ContentUnavailableView(
                    "Your meals will be shown here.",
                    systemImage: "fork.knife",
                    description: Text("You can add a meal by tapping the \"+\" icon.")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.plusButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("Meals")
        .onFirstAppear {
            store.send(.onFirstAppear)
        }
        .navigationDestination(
            item: self.$store.scope(state: \.mealDetails, action: \.mealDetails),
            destination: { store in
                MealDetails(store: store)
            }
        )
        .sheet(
            item: $store.scope(state: \.mealForm, action: \.mealForm),
            content: { store in
                NavigationStack {
                    MealForm(store: store)
                }
                .interactiveDismissDisabled()
            }
        )
    }

    private var mealsSection: some View {
        Section {
            ForEach(store.meals, id: \.id) { meal in
                ListButton {
                    self.store.send(.mealTapped(meal))
                } label: {
                    let nutritionalValuesPerServingSize = calculator.nutritionalValuesPerServingSize(for: meal)
                    let footnotePerServingSize = "Per serving: \(nutritionalValuesPerServingSize.foodWithQuantity.nutritionalSummary)"
                    let nutritionalValuesPerTotal = calculator.nutritionalValues(for: meal)
                    let footnotePerTotal = nutritionalValuesPerTotal.food.nutritionalSummary
                    let footnote = meal.servings != 1 ? footnotePerServingSize : footnotePerTotal
                    LabeledListRow(
                        title: meal.name.capitalized,
                        footnote: footnote
                    )
                }
            }
            .onDelete { offsets in
                self.store.send(.onDelete(offsets))
            }
        }
    }
}

#Preview {
    MealList(
        store: .init(
            initialState: MealListFeature.State(),
            reducer: {
                MealListFeature()
            }
        )
    )
}
