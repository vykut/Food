import SwiftUI
import ComposableArchitecture
import Ads
import Spotlight
import Shared
import FoodDetails

public struct FoodList: View {
    typealias State = FoodListFeature.State

    @Bindable var store: StoreOf<FoodListFeature>

    public init(store: StoreOf<FoodListFeature>) {
        self.store = store
    }

    public var body: some View {
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
                item: $store.scope(state: \.destination?.foodDetails, action: \.destination.foodDetails)
            ) { store in
                FoodDetails(store: store)
            }
            .navigationTitle("Search")
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .onFirstAppear {
                self.store.send(.onFirstAppear)
            }
            .onContinueUserActivity(CSSearchableItemActionType) { activity in
                store.send(.spotlight(.handleSelectedFood(activity)))
            }
            .onContinueUserActivity(CSQueryContinuationActionType) { activity in
                store.send(.spotlight(.handleSearchInApp(activity)))
            }
    }

    @MainActor @ViewBuilder
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
            ForEach(self.store.recentFoods, id: \.id) { item in
                ListButton {
                    self.store.send(.didSelectRecentFood(item))
                } label: {
                    FoodListRow(food: item)
                }
            }
            .onDelete { offsets in
                self.store.send(.didDeleteRecentFoods(offsets))
            }
        } header: {
            Text("Recent Searches")
        } footer: {
            Text("Values per \(Quantity.grams( 100).formatted(width: .wide))")
                .font(.footnote)
        }
    }

    private var searchResultsList: some View {
        Section {
            ForEach(self.store.searchResults, id: \.self) { item in
                ListButton {
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
            sortRecentFoodsMenu
        }
    }

    private var sortRecentFoodsMenu: some View {
        Menu {
            Picker(
                "Sort by",
                selection: self.$store.recentFoodsSortingStrategy.sending(\.updateRecentFoodsSortingStrategy)
            ) {
                ForEach(State.SortingStrategy.allCases) { strategy in
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
        .disabled(store.isSortMenuDisabled)
    }
}

#Preview {
    FoodList(
        store: .init(
            initialState: FoodListFeature.State(),
            reducer: {
                FoodListFeature()
                    .transformDependency(\.databaseClient) {
                        $0.observeFoods = { _, _ in
                            .init {
                                $0.yield([.preview(id: 1), .preview(id: 2), .preview(id: 3)])
                            }
                        }
                    }
                    ._printChanges()
            }
        )
    )
}
