import SwiftUI
import Shared
import MealForm
import MealDetails
import DatabaseObservation
import Search
import ComposableArchitecture

public struct MealListScreen: View {
    @Bindable var store: StoreOf<MealList>

    public init(store: StoreOf<MealList>) {
        self.store = store
    }

    public var body: some View {
        List {
            if self.store.mealSearch.shouldShowSearchResults {
                searchResultsSection
            } else if !self.store.mealsWithNutritionalValues.isEmpty {
                mealsSection
            } else {
                ContentUnavailableView(
                    "Your meals will be shown here.",
                    systemImage: "takeoutbag.and.cup.and.straw.fill",
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
        .mealSearch(
            store: self.store.scope(
                state: \.mealSearch,
                action: \.mealSearch
            )
        )
        .mealObservation(
            store: self.store.scope(
                state: \.mealObservation,
                action: \.mealObservation
            )
        )
        .navigationTitle("Meals")
        .navigationDestination(
            item: self.$store.scope(
                state: \.destination?.mealDetails,
                action: \.destination.mealDetails
            ),
            destination: { store in
                MealDetailsScreen(store: store)
            }
        )
        .sheet(
            item: $store.scope(
                state: \.destination?.mealForm,
                action: \.destination.mealForm
            ),
            content: { store in
                NavigationStack {
                    MealFormScreen(store: store)
                }
                .interactiveDismissDisabled()
            }
        )
    }

    private var searchResultsSection: some View {
        Section {
            ForEach(store.searchResults, id: \.meal.id) { nutritionalValue in
                button(for: nutritionalValue)
            }
        }
    }

    private var mealsSection: some View {
        Section {
            ForEach(store.mealsWithNutritionalValues, id: \.meal.id) { nutritionalValue in
                button(for: nutritionalValue)
            }
            .onDelete { offsets in
                self.store.send(.onDelete(offsets))
            }
        }
    }

    private func button(for nutritionalValue: MealList.State.MealWithNutritionalValues) -> some View {
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
}

#Preview {
    MealListScreen(
        store: .init(
            initialState: MealList.State(),
            reducer: {
                MealList()
            }
        )
    )
}
