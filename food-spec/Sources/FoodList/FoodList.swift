import Foundation
import Database
import ComposableArchitecture
import Shared
import Search
import Ads
import FoodDetails
import FoodObservation
import UserPreferences

@Reducer
public struct FoodList {
    @ObservableState
    public struct State: Equatable {
        var foodSearch: FoodSearch.State
        var billboard: Billboard = .init()
        @Presents var destination: Destination.State?

        var recentFoods: [Food] {
            foodSearch.foodObservation.foods
        }

        var recentFoodsSortStrategy: FoodObservation.State.SortStrategy {
            foodSearch.foodObservation.sortStrategy
        }

        var recentFoodsSortOrder: SortOrder {
            foodSearch.foodObservation.sortOrder
        }

        var shouldShowRecentSearches: Bool {
            foodSearch.query.isEmpty &&
            !recentFoods.isEmpty
        }

        var shouldShowPrompt: Bool {
            foodSearch.query.isEmpty && recentFoods.isEmpty
        }

        var isSearching: Bool {
            foodSearch.isSearching
        }

        var shouldShowSpinner: Bool {
            isSearching
        }

        var isSortMenuDisabled: Bool {
            recentFoods.count < 2
        }

        public init() { 
            @Dependency(\.userPreferencesClient) var userPreferencesClient
            let prefs = userPreferencesClient.getPreferences()
            self.foodSearch = .init(
                foodObservation: .init(
                    sortStrategy: prefs.foodSortingStrategy ?? .name,
                    sortOrder: prefs.recentSearchesSortingOrder ?? .forward
                )
            )
        }
    }

    @CasePathable
    public enum Action {
        case onFirstAppear
        case onUserPreferencesChange(UserPreferences)
        case didSelectRecentFood(Food)
        case didSelectSearchResult(Food)
        case didDeleteRecentFoods(IndexSet)
        case foodSearch(FoodSearch.Action)
        case updateRecentFoodsSortingStrategy(FoodObservation.State.SortStrategy)
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
        Scope(state: \.foodSearch, action: \.foodSearch) {
            FoodSearch()
        }
        Reduce { state, action in
            switch action {
                case .onFirstAppear:
                    return .run { [userPreferencesClient] send in
                        let stream = await userPreferencesClient.observeChanges()
                        for await preferences in stream {
                            await send(.onUserPreferencesChange(preferences))
                        }
                    }

                case .foodSearch(.foodObservation(.updateFoods)):
                    if state.foodSearch.foodObservation.foods.isEmpty && state.foodSearch.query.isEmpty {
                        state.foodSearch.isFocused = true
                    }
                    return .none

                case .onUserPreferencesChange(let preferences):
                    return .send(.foodSearch(.foodObservation(.updateSortStrategy(
                        preferences.foodSortingStrategy ?? .name,
                        preferences.recentSearchesSortingOrder ?? .forward
                    ))))

                case .foodSearch(.error):
                    guard state.foodSearch.isSearching else { return .none }
                    if state.foodSearch.hasNoResults {
                        showGenericAlert(state: &state)
                    }
                    return .none

                case .foodSearch:
                    return .none

                case .didSelectRecentFood(let food):
                    state.destination = .foodDetails(.init(food: food))
                    return .none

                case .didSelectSearchResult(let food):
                    state.destination = .foodDetails(.init(food: food))
                    return .none

                case .didDeleteRecentFoods(let indices):
                    return .run { [recentFoods = state.recentFoods, databaseClient] send in
                        let foodsToDelete = indices.map { recentFoods[$0] }
                        try await databaseClient.delete(foods: foodsToDelete)
                    } catch: { error, send in
                        await send(.showGenericAlert)
                    }

                case .updateRecentFoodsSortingStrategy(let newStrategy):
                    let sortOrder: SortOrder = newStrategy == state.foodSearch.foodObservation.sortStrategy ? state.foodSearch.foodObservation.sortOrder.toggled() : .forward
                    return .run { send in
                        try await userPreferencesClient.setPreferences {
                            $0.foodSortingStrategy = newStrategy
                            $0.recentSearchesSortingOrder = sortOrder
                        }
                    }

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

fileprivate extension UserPreferences {
    var foodSortingStrategy: FoodObservation.State.SortStrategy? {
        get {
            recentSearchesSortingStrategy.flatMap { .init(rawValue: $0) }
        }
        set {
            recentSearchesSortingStrategy = newValue?.rawValue
        }
    }
}
