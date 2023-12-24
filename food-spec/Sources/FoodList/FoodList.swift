import Foundation
import Database
import ComposableArchitecture
import Shared
import FoodDetails
import UserPreferences
import Search
import DatabaseObservation

@Reducer
public struct FoodList: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var foodSearch: FoodSearch.State
        public var foodObservation: FoodObservation.State
        public var recentSearches: [Food] = []
        public var sortStrategy: Food.SortStrategy
        public var sortOrder: SortOrder
        @Presents public var destination: Destination.State?

        var showsSearchPrompt: Bool {
            !foodSearch.shouldShowSearchResults &&
            recentSearches.isEmpty
        }

        var searchResults: [Food] {
            foodSearch.searchResults
        }

        var isSortMenuDisabled: Bool {
            recentSearches.count < 2
        }

        public init() { 
            @Dependency(\.userPreferencesClient) var userPreferencesClient
            let prefs = userPreferencesClient.getPreferences()
            let sortStrategy = prefs.recentSearchesSortStrategy ?? .name
            let sortOrder = prefs.recentSearchesSortOrder ?? .forward
            self.sortStrategy = sortStrategy
            self.sortOrder = sortOrder
            self.foodSearch = .init(
                sortStrategy: sortStrategy,
                sortOrder: sortOrder
            )
            self.foodObservation = .init(
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
        case foodSearch(FoodSearch.Action)
        case foodObservation(FoodObservation.Action)
        case updateRecentFoodsSortingStrategy(Food.SortStrategy)
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
        Scope(state: \.foodSearch, action: \.foodSearch) {
            FoodSearch()
        }
        Scope(state: \.foodObservation, action: \.foodObservation) {
            FoodObservation()
        }
        Reduce { state, action in
            switch action {
                case .onFirstAppear:
                    return .none

                case .didSelectRecentFood(let food):
                    state.destination = .foodDetails(.init(food: food))
                    return .none

                case .didSelectSearchResult(let food):
                    state.destination = .foodDetails(.init(food: food))
                    return .none

                case .didDeleteRecentFoods(let indices):
                    return .run { [foods = state.recentSearches] send in
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
                        .send(.foodSearch(.updateSortStrategy(newStrategy, state.sortOrder)), animation: .default),
                        .send(.foodObservation(.updateSortStrategy(newStrategy, state.sortOrder)), animation: .default),
                        .run { [order = state.sortOrder] send in
                            try await userPreferencesClient.setPreferences {
                                $0.recentSearchesSortStrategy = newStrategy
                                $0.recentSearchesSortOrder = order
                            }
                        }
                    )

                case .foodObservation(.delegate(.foodsChanged(let newFoods))):
                    state.recentSearches = newFoods
                    if newFoods.isEmpty && state.foodSearch.query.isEmpty {
                        state.foodSearch.isFocused = true
                    }
                    return .none

                case .foodSearch:
                    return .none

                case .foodObservation:
                    return .none

                case .showGenericAlert:
                    showGenericAlert(state: &state)
                    return .none

                case .destination:
                    return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
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
