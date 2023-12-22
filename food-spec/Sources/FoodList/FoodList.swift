import Foundation
import Database
import ComposableArchitecture
import Shared
import Ads
import FoodDetails
import UserPreferences
import SearchableFoodList

@Reducer
public struct FoodList {
    @ObservableState
    public struct State: Equatable {
        var searchableFoodList: SearchableFoodList.State
        var sortStrategy: Food.SortStrategy
        var sortOrder: SortOrder
        var billboard: Billboard = .init()
        @Presents var destination: Destination.State?

        var recentSearches: [Food] {
            searchableFoodList.foods
        }

        var isSortMenuDisabled: Bool {
            searchableFoodList.foods.count < 2
        }

        public init() { 
            @Dependency(\.userPreferencesClient) var userPreferencesClient
            let prefs = userPreferencesClient.getPreferences()
            let sortStrategy = prefs.recentSearchesSortStrategy ?? .name
            let sortOrder = prefs.recentSearchesSortOrder ?? .forward
            self.sortStrategy = sortStrategy
            self.sortOrder = sortOrder
            self.searchableFoodList = .init(
                sortStrategy: sortStrategy,
                sortOrder: sortOrder
            )
        }
    }

    @CasePathable
    public enum Action {
        case onFirstAppear
        case didSelectRecentFood(Food)
        case didSelectSearchResult(Food)
        case didDeleteRecentFoods(IndexSet)
        case searchableFoodList(SearchableFoodList.Action)
        case updateRecentFoodsSortingStrategy(Food.SortStrategy)
        case billboard(Billboard)
        case spotlight(Spotlight)
        case showGenericAlert
        case destination(PresentationAction<Destination.Action>)
    }

    enum CancelID {
        case search
        case recentFoodsObservation
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.userPreferencesClient) private var userPreferencesClient

    public var body: some ReducerOf<Self> {
        Scope(state: \.searchableFoodList, action: \.searchableFoodList) {
            SearchableFoodList()
        }
        Reduce { state, action in
            switch action {
                case .onFirstAppear:
                    return .none
                    
                case .searchableFoodList:
                    return .none

                case .didSelectRecentFood(let food):
                    state.destination = .foodDetails(.init(food: food))
                    return .none

                case .didSelectSearchResult(let food):
                    state.destination = .foodDetails(.init(food: food))
                    return .none

                case .didDeleteRecentFoods(let indices):
                    return .run { [foods = state.searchableFoodList.foods] send in
                        let foodsToDelete = indices.map { foods[$0] }
                        try await databaseClient.delete(foods: foodsToDelete)
                    } catch: { error, send in
                        await send(.showGenericAlert)
                    }

                case .updateRecentFoodsSortingStrategy(let newStrategy):
                    if newStrategy == state.sortStrategy {
                        state.sortOrder.toggle()
                    } else {
                        state.sortStrategy = newStrategy
                        state.sortOrder = .forward
                    }
                    return .merge(
                        .send(.searchableFoodList(.updateSortStrategy(
                            newStrategy,
                            state.sortOrder
                        ))),
                        .run { [order = state.sortOrder] send in
                            try await userPreferencesClient.setPreferences {
                                $0.recentSearchesSortStrategy = newStrategy
                                $0.recentSearchesSortOrder = order
                            }
                        }
                    )

                case .showGenericAlert:
                    showGenericAlert(state: &state)
                    return .none

                case .billboard:
                    // handled in BillboardReducer
                    return .none

                case .spotlight:
                    // handled in SpotlightReducer
                    return .none

                case .destination:
                    return .none
            }
        }
        .onChange(of: \.searchableFoodList.foods) { _, newFoods in
            Reduce { state, _ in
                if newFoods.isEmpty && state.searchableFoodList.foodSearch.query.isEmpty {
                    state.searchableFoodList.foodSearch.isFocused = true
                }
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
        SpotlightReducer()
        BillboardReducer()
    }

    private func showGenericAlert(state: inout State) {
        state.destination = .alert(.init {
            TextState("Something went wrong. Please try again later.")
        })
    }

    @Reducer
    public struct Destination {
        @ObservableState
        public enum State: Hashable {
            case foodDetails(FoodDetails.State)
            case alert(AlertState<Action.Alert>)
        }

        @CasePathable
        public enum Action {
            case foodDetails(FoodDetails.Action)
            case alert(Alert)

            @CasePathable
            public enum Alert: Hashable { }
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.foodDetails, action: \.foodDetails) {
                FoodDetails()
            }
        }
    }
}
