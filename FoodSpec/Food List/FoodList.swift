//
//  ContentView.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
import CoreSpotlight

struct FoodList: View {
    @Bindable var store: StoreOf<FoodListReducer>

    var body: some View {
        NavigationStack {
            list
                .toolbar {
                    toolbar
                }
                .searchable(
                    text: self.$store.searchQuery.sending(\.updateSearchQuery),
                    isPresented: self.$store.isSearchFocused.sending(\.updateSearchFocus),
                    placement: .navigationBarDrawer
                )
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
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            store.send(.handleSpotlightSelectedFood(activity))
        }
    }

    @ViewBuilder
    private var list: some View {
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
            .overlay {
                if self.store.isSearching {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
    }

    private var recentSearches: some View {
        Section {
            ForEach(self.store.recentFoods, id: \.self) { item in
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

    private var toolbar: some View {
        Menu("Menu", systemImage: "ellipsis.circle") {
            Picker(
                "Sort by",
                selection: self.$store.recentFoodsSortingStrategy.sending(\.updateRecentFoodsSortingStrategy)
            ) {
                ForEach(Food.SortingStrategy.allCases) { strategy in
                    let text = strategy.rawValue.capitalized
                    ZStack {
                        if strategy == self.store.recentFoodsSortingStrategy {
                            let systemImageName = self.store.recentFoodsSortingOrder == .forward ? "chevron.up" : "chevron.down"
                            Label(text, systemImage: systemImageName)
                        } else {
                            Text(text)
                        }
                    }
                    .tag(strategy)
                }
            }
        }
        .menuActionDismissBehavior(.disabled)
    }

    private func deleteItems(offsets: IndexSet) {
        self.store.send(.didDeleteRecentFoods(offsets))
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
