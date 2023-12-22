import SwiftUI
import Shared
import Search
import FoodObservation
import ComposableArchitecture

public struct SearchableFoodScrollView<SearchResults: View, Default: View>: View {
    @Bindable var store: StoreOf<SearchableFoodList>
    let spacing: CGFloat?
    @ViewBuilder let searchResults: (Food) -> SearchResults
    @ViewBuilder let defaultView: ([Food]) -> Default

    public init(
        store: StoreOf<SearchableFoodList>,
        spacing: CGFloat? = nil,
        @ViewBuilder searchResults: @escaping (Food) -> SearchResults,
        @ViewBuilder defaultView: @escaping ([Food]) -> Default
    ) {
        self.store = store
        self.spacing = spacing
        self.searchResults = searchResults
        self.defaultView = defaultView
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: spacing) {
                if self.store.foodSearch.shouldShowSearchResults {
                    searchResultsSection
                } else if !self.store.foods.isEmpty {
                    defaultView(self.store.foodObservation.foods)
                } else {
                    ContentUnavailableView("Search for food", systemImage: "magnifyingglass")
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .searchableFood(
            store: self.store.scope(state: \.foodSearch, action: \.foodSearch)
        )
        .foodObservation(
            store: self.store.scope(state: \.foodObservation, action: \.foodObservation)
        )
        .alert(self.$store.scope(state: \.alert, action: \.alert))
    }

    @ViewBuilder
    private var searchResultsSection: some View {
        ForEach(self.store.searchResults, id: \.id) { item in
            self.searchResults(item)
        }
        if self.store.foodSearch.shouldShowNoResults {
            ContentUnavailableView.search(text: self.store.foodSearch.query)
                .id(UUID())
        }
        if self.store.foodSearch.isSearching {
            HStack {
                Spacer()
                ProgressView("Searching...")
                    .id(UUID())
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchableFoodListView(
            store: .init(
                initialState: SearchableFoodList.State(),
                reducer: {
                    SearchableFoodList()
                },
                withDependencies: {
                    $0.databaseClient.observeFoods = { _, _ in
                            .init {
                                $0.yield([.preview])
                            }
                    }
                    $0.databaseClient.getFoods = { query, _, _ in
                        let food = Food.preview
                        if food.name.contains(query.lowercased()) {
                            return [food]
                        } else {
                            return []
                        }
                    }
                }
            )
        ) { food in
            LabeledListRow(
                title: food.name.capitalized,
                footnote: food.nutritionalSummary
            )
        } defaultView: { foods in
            Section("Recent Searches") {
                ForEach(foods, id: \.id) { food in
                    LabeledListRow(
                        title: food.name.capitalized,
                        footnote: food.nutritionalSummary
                    )
                }
            }
        }
    }
}
