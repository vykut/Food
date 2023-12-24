import SwiftUI
import ComposableArchitecture
import Shared
import FoodComparison
import Search

public struct FoodSelectionScreen: View {
    @Bindable var store: StoreOf<FoodSelection>

    public init(store: StoreOf<FoodSelection>) {
        self.store = store
    }

    public var body: some View {
        List(selection: self.$store.selectedFoodIds.sending(\.updateSelection).animation()) {
            if self.store.foodSearch.shouldShowSearchResults {
                searchResultsSection
            } else if !self.store.foods.isEmpty {
                recentSearchesSection
            } else {
                ContentUnavailableView("Search for food", systemImage: "magnifyingglass")
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbar
        }
        .foodSearch(
            store: self.store.scope(
                state: \.foodSearch,
                action: \.foodSearch
            )
        )
        .foodObservation(
            store: self.store.scope(
                state: \.foodObservation,
                action: \.foodObservation
            )
        )
        .navigationDestination(
            item: self.$store.scope(state: \.foodComparison, action: \.foodComparison),
            destination: { store in
                FoodComparisonScreen(store: store)
            }
        )
    }

    private var searchResultsSection: some View {
        Section {
            ForEach(self.store.searchResults, id: \.id) { item in
                LabeledListRow(title: item.name.capitalized)
                    .selectionDisabled(self.store.state.isSelectionDisabled(for: item))
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

    private var recentSearchesSection: some View {
        Section {
            ForEach(self.store.foods, id: \.id) { item in
                LabeledListRow(title: item.name.capitalized)
                    .selectionDisabled(self.store.state.isSelectionDisabled(for: item))
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if self.store.shouldShowCancelButton {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    self.store.send(.cancelButtonTapped)
                }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu("Compare") {
                ForEach(Comparison.allCases) { comparison in
                    Button(comparison.rawValue.capitalized) {
                        self.store.send(.compareButtonTapped(comparison))
                    }
                }
            }
            .disabled(self.store.isCompareButtonDisabled)
        }
    }

    private var navigationTitle: String {
        if self.store.selectedFoodIds.count < 2 {
            "Select \(2 - store.selectedFoodIds.count) or more"
        } else {
            "\(self.store.selectedFoodIds.count) foods selected"
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
