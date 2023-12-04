//
//  ContentView.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct FoodList: View {
    @Bindable var store: StoreOf<FoodListReducer>

    var body: some View {
        NavigationStack {
            ZStack {
                if let store = store.scope(state: \.inlineFood, action: \.inlineFood) {
                    FoodDetails(store: store)
                } else {
                    List {
                        if self.store.shouldShowRecentSearches {
                            recentSearches
                        }
                        if self.store.shouldShowPrompt {
                            ContentUnavailableView("Search for food", systemImage: "magnifyingglass")
                        }
                        if self.store.shouldShowSearchResults {
                            searchResultsList
                        }
                        if self.store.shouldShowNoResults {
                            ContentUnavailableView.search(text: self.store.searchQuery)
                        }
                    }
                    .listStyle(.sidebar)
                }
            }
            .searchable(
                text: self.$store.searchQuery.sending(\.updateSearchQuery),
                isPresented: self.$store.isSearchFocused.sending(\.updateSearchFocus)
            )
            .toolbar {
                Menu("Menu", systemImage: "ellipsis.circle") {
                    Picker(
                        "Sort",
                        selection: self.$store.recentFoodsSortingStrategy.sending(\.updateRecentFoodsSortingStrategy)
                    ) {
                        ForEach(Food.SortingStrategy.allCases) { strategy in
                            let text = strategy.text.capitalized
                            if strategy == self.store.recentFoodsSortingStrategy {
                                Label(text, systemImage: self.store.recentFoodsSortingOrder == .forward ? "chevron.up" : "chevron.down")
                            } else {
                                Text(text)
                                    .tag(strategy)
                            }
                        }
                    }
                }
            }
            .overlay {
                if self.store.isSearching {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.foodDetails, action: \.foodDetails)
            ) { store in
                FoodDetails(store: store)
            }
            .navigationTitle("Search")
        }
        .onAppear {
            self.store.send(.onAppear)
        }
    }

    private var recentSearches: some View {
        Section {
            ForEach(self.store.recentFoods) { item in
                Button {
                    self.store.send(.didSelectRecentFood(item))
                } label: {
                    FoodListRow(food: item)
                }
            }
            .onDelete(perform: deleteItems)
        } header: {
            Text("Recent Searches")
        }
    }

    private var searchResultsList: some View {
        Section {
            ForEach(self.store.searchResults, id: \.self) { item in
                Button {
                    self.store.send(.didSelectSearchResult(item))
                } label: {
                    FoodListRow(food: item)
                }
            }
        } header: {
            Text("Results")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        self.store.send(.didDeleteRecentFoods(offsets), animation: .default)
    }
}

#Preview {
    FoodList(
        store: .init(
            initialState: FoodListReducer.State(),
            reducer: {
                FoodListReducer()
                    ._printChanges()
            }
        )
    )
}
