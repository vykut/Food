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
import Billboard

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
                .safeAreaInset(edge: .bottom) {
                    if let ad = store.billboard.banner {
                        BillboardBannerView(advert: ad, hideDismissButtonAndTimer: true)
                            .padding([.horizontal, .bottom])
                    }
                }
                .navigationDestination(
                    item: $store.scope(state: \.foodDetails, action: \.foodDetails)
                ) { store in
                    FoodDetails(store: store)
                }
                .navigationTitle("Search")
        }
        .sheet(
            item: $store.scope(state: \.foodComparison, action: \.foodComparison)
        ) { store in
            NavigationStack {
                FoodSelection(store: store)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            self.store.send(.onAppear)
        }
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            store.send(.spotlight(.handleSelectedFood(activity)))
        }
        .onContinueUserActivity(CSQueryContinuationActionType) { activity in
            store.send(.spotlight(.handleSearchInApp(activity)))
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
        } footer: {
            Text("Values per \(Quantity(grams: 100).formatted(width: .wide))")
                .font(.footnote)
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

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            compareButton
            sortRecentFoodsMenu
        }
    }

    private var compareButton: some View {
        Button("Compare") {
            store.send(.didTapCompare)
        }
    }

    private var sortRecentFoodsMenu: some View {
        Menu {
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
                                .imageScale(.small)
                        } else {
                            Text(text)
                        }
                    }
                    .tag(strategy)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .imageScale(.medium)
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
                    .transformDependency(\.databaseClient) {
                        $0.observeFoods = { _, _ in
                            .init {
                                $0.yield([.preview, .preview, .preview])
                            }
                        }
                    }
                    ._printChanges()
            }
        )
    )
}
