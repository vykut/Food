import SwiftUI
import Shared
import MealForm
import MealDetails
import ComposableArchitecture

public struct MealList: View {
    @Bindable var store: StoreOf<MealListFeature>

    public init(store: StoreOf<MealListFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            if store.showsAddMealPrompt {
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
            ForEach(store.mealsWithNutritionalValues, id: \.meal.id) { nutritionalValue in
                ListButton {
                    self.store.send(.mealTapped(nutritionalValue.meal))
                } label: {
                    let footnotePerServingSize = "Per serving: \(nutritionalValue.perServing.foodWithQuantity.nutritionalSummary)"
                    let footnotePerTotal = nutritionalValue.perTotal.foodWithQuantity.nutritionalSummary
                    let footnote = nutritionalValue.meal.servings != 1 ? footnotePerServingSize : footnotePerTotal
                    LabeledListRow(
                        title: nutritionalValue.meal.name.capitalized,
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
