import SwiftUI
import ComposableArchitecture
import Shared
import Search
import FoodComparison

public struct FoodSelectionScreen: View {
    @Bindable var store: StoreOf<FoodSelection>

    public init(store: StoreOf<FoodSelection>) {
        self.store = store
    }

    public var body: some View {
        List(selection: $store.selectedFoodIds.sending(\.updateSelection)) {
            if self.store.foodSearch.shouldShowSearchResults {
                searchResultsSection
            } else if !self.store.foods.isEmpty {
                recentSearchesSection
            }else if self.store.shouldShowPrompt {
                ContentUnavailableView("Search for food", systemImage: "magnifyingglass")
            }
        }
        .listStyle(.sidebar)
        .searchableFood(
            store: self.store.scope(state: \.foodSearch, action: \.foodSearch)
        )
        .environment(\.editMode, .constant(.active))
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbar
        }
        .navigationDestination(
            item: $store.scope(state: \.foodComparison, action: \.foodComparison),
            destination: { store in
                FoodComparisonScreen(store: store)
            }
        )
    }

    private var recentSearchesSection: some View {
        Section("Recent searches") {
            ForEach(store.foods, id: \.id) { item in
                LabeledListRow(title: item.name.capitalized)
                    .selectionDisabled(store.state.isSelectionDisabled(for: item))
            }
        }
    }

    private var searchResultsSection: some View {
        Section("Results") {
            ForEach(store.searchResults, id: \.id) { item in
                LabeledListRow(title: item.name.capitalized)
                    .selectionDisabled(store.state.isSelectionDisabled(for: item))
            }

            if self.store.foodSearch.shouldShowNoResults {
                ContentUnavailableView.search(text: self.store.foodSearch.query)
                    .id(UUID())
            }

            if self.store.foodSearch.isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                        .id(UUID())
                    Spacer()
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if store.shouldShowCancelButton {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu("Compare") {
                ForEach(Comparison.allCases) { comparison in
                    Button(comparison.rawValue.capitalized) {
                        store.send(.compareButtonTapped(comparison))
                    }
                }
            }
            .disabled(store.isCompareButtonDisabled)
        }
    }

    private var navigationTitle: String {
        if store.selectedFoodIds.count < 2 {
            "Select \(2 - store.selectedFoodIds.count) or more"
        } else {
            "\(store.selectedFoodIds.count) foods selected"
        }
    }
}

#Preview {
    NavigationStack {
        FoodSelectionScreen(
            store: .init(
                initialState: FoodSelection.State(),
                reducer: {
                    FoodSelection()
                        ._printChanges()
                }
            )
        )
    }
}

fileprivate extension Food {
    init(id: Int64, name: String) {
        self.init(
            id: id,
            name: name,
            energy: .zero,
            fatTotal: .zero,
            fatSaturated: .zero,
            protein: .zero,
            sodium: .zero,
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .zero,
            fiber: .zero,
            sugar: .zero
        )
    }
}
