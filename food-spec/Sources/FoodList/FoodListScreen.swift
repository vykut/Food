import SwiftUI
import ComposableArchitecture
import Ads
import Spotlight
import Shared
import SearchableFoodList
import FoodDetails

public struct FoodListScreen: View {
    @Bindable var store: StoreOf<FoodList>

    public init(store: StoreOf<FoodList>) {
        self.store = store
    }

    public var body: some View {
        SearchableFoodListView(
            store: self.store.scope(
                state: \.searchableFoodList,
                action: \.searchableFoodList
            )
        ) { food in
            ListButton {
                self.store.send(.didSelectSearchResult(food))
            } label: {
                FoodListRow(food: food)
            }
        } defaultView: { _ in
            recentSearchesSection
        }
        .toolbar {
            toolbar
        }
        .safeAreaInset(edge: .bottom) {
            if let ad = self.store.billboard.banner {
                BillboardBannerView(advert: ad, hideDismissButtonAndTimer: true)
                    .padding([.horizontal, .bottom])
            }
        }
        .navigationDestination(
            item: self.$store.scope(state: \.destination?.foodDetails, action: \.destination.foodDetails)
        ) { store in
            FoodDetailsScreen(store: store)
        }
        .navigationTitle("Search")
        .alert(self.$store.scope(state: \.destination?.alert, action: \.destination.alert))
        .onFirstAppear {
            self.store.send(.onFirstAppear)
        }
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            self.store.send(.spotlight(.handleSelectedFood(activity)))
        }
        .onContinueUserActivity(CSQueryContinuationActionType) { activity in
            self.store.send(.spotlight(.handleSearchInApp(activity)))
        }
    }

    private var recentSearchesSection: some View {
        Section {
            ForEach(self.store.recentSearches, id: \.id) { item in
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
            Text("Values per \(Quantity.grams(100).formatted(width: .wide))")
                .font(.footnote)
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
                selection: self.$store.sortStrategy.sending(\.updateRecentFoodsSortingStrategy)
            ) {
                ForEach(Food.SortStrategy.allCases) { strategy in
                    let text = strategy.rawValue.capitalized
                    ZStack {
                        if strategy == self.store.sortStrategy {
                            let systemImageName = self.store.sortOrder == .forward ? "chevron.up" : "chevron.down"
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
        .disabled(self.store.isSortMenuDisabled)
    }
}

#Preview {
    FoodListScreen(
        store: .init(
            initialState: FoodList.State(),
            reducer: {
                FoodList()
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
