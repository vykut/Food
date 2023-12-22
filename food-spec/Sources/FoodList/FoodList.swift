import Foundation
import Database
import ComposableArchitecture
import Shared
import Search
import Ads
import FoodDetails
import UserPreferences

@Reducer
public struct FoodList {
    @ObservableState
    public struct State: Equatable {
        var recentFoods: [Food] = []
        var foodSearch: FoodSearch.State = .init()
        var recentFoodsSortingStrategy: SortingStrategy
        var recentFoodsSortingOrder: SortOrder
        var billboard: Billboard = .init()
        @Presents var destination: Destination.State?

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

        public enum SortingStrategy: String, Codable, Identifiable, Hashable, CaseIterable, Sendable {
            case name
            case energy
            case carbohydrate
            case protein
            case fat

            public var id: Self { self }

            var column: Column {
                switch self {
                    case .name: Column("name")
                    case .energy: Column("energy")
                    case .carbohydrate: Column("carbohydrate")
                    case .protein: Column("protein")
                    case .fat: Column("fatTotal")
                }
            }
        }

        public init() { 
            @Dependency(\.userPreferencesClient) var userPreferencesClient
            let prefs = userPreferencesClient.getPreferences()
            self.recentFoodsSortingStrategy = prefs.foodSortingStrategy ?? .name
            self.recentFoodsSortingOrder = prefs.recentSearchesSortingOrder ?? .forward
        }
    }

    @CasePathable
    public enum Action {
        case onFirstAppear
        case startObservingRecentFoods
        case onRecentFoodsChange([Food])
        case onUserPreferencesChange(UserPreferences)
        case didSelectRecentFood(Food)
        case didSelectSearchResult(Food)
        case didDeleteRecentFoods(IndexSet)
        case foodSearch(FoodSearch.Action)
        case updateRecentFoodsSortingStrategy(State.SortingStrategy)
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
                    return .run { send in
                        await send(.startObservingRecentFoods)
                    }.merge(with: .run { [userPreferencesClient] send in
                        let stream = await userPreferencesClient.observeChanges()
                        for await preferences in stream {
                            await send(.onUserPreferencesChange(preferences))
                        }
                    })

                case .startObservingRecentFoods:
                    return .run { [databaseClient, strategy = state.recentFoodsSortingStrategy, order = state.recentFoodsSortingOrder] send in
                        let stream = databaseClient.observeFoods(sortedBy: strategy.column, order: order)
                        for await foods in stream {
                            await send(.onRecentFoodsChange(foods), animation: .default)
                        }
                    }
                    .cancellable(id: CancelID.recentFoodsObservation, cancelInFlight: true)

                case .onRecentFoodsChange(let foods):
                    state.recentFoods = foods
                    if foods.isEmpty && state.foodSearch.query.isEmpty {
                        state.foodSearch.isFocused = true
                    }
                    return .none

                case .onUserPreferencesChange(let preferences):
                    var shouldRestartDatabaseObservation = false
                    if let newStrategy = preferences.foodSortingStrategy, newStrategy != state.recentFoodsSortingStrategy {
                        state.recentFoodsSortingStrategy = newStrategy
                        shouldRestartDatabaseObservation = true
                    }
                    if let newOrder = preferences.recentSearchesSortingOrder, newOrder != state.recentFoodsSortingOrder {
                        state.recentFoodsSortingOrder = newOrder
                        shouldRestartDatabaseObservation = true
                    }
                    if shouldRestartDatabaseObservation {
                        return .send(.startObservingRecentFoods)
                    } else {
                        return .none
                    }

                case .foodSearch(let action):
                    return reduce(state: &state, action: action)

                case .didSelectRecentFood(let food):
                    state.destination = .foodDetails(.init(food: food))
                    return .none

                case .didSelectSearchResult(let food):
                    state.destination = .foodDetails(.init(food: food))
                    return .none

                case .didDeleteRecentFoods(let indices):
                    return .run { [recentFoods = state.recentFoods, databaseClient] send in
                        let foodsToDelete = indices.map { recentFoods[$0] }
                        for food in foodsToDelete {
                            try await databaseClient.delete(food: food)
                        }
                    } catch: { error, send in
                        await send(.showGenericAlert)
                    }

                case .updateRecentFoodsSortingStrategy(let newStrategy):
                    if newStrategy == state.recentFoodsSortingStrategy {
                        state.recentFoodsSortingOrder.toggle()
                    } else {
                        state.recentFoodsSortingStrategy = newStrategy
                        state.recentFoodsSortingOrder = .forward
                    }
                    return .run { [strategy = state.recentFoodsSortingStrategy, order = state.recentFoodsSortingOrder] send in
                        try await userPreferencesClient.setPreferences {
                            $0.foodSortingStrategy = strategy
                            $0.recentSearchesSortingOrder = order
                        }
                        await send(.startObservingRecentFoods)
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

    private func reduce(state: inout State, action: FoodSearch.Action) -> EffectOf<Self> {
        switch action {
            case .updateQuery:
                return .none

            case .updateFocus:
                return .none

            case .error(let error):
                guard state.foodSearch.isSearching else { return .none }
                if state.foodSearch.hasNoResults {
                    showGenericAlert(state: &state)
                }
                return .none

            case .searchStarted:
                return .none

            case .searchEnded:
                return .none

            case .searchSubmitted:
                return .none

            case .result(_):
                return .none
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

fileprivate extension UserPreferences {
    var foodSortingStrategy: FoodList.State.SortingStrategy? {
        get {
            recentSearchesSortingStrategy.flatMap { .init(rawValue: $0) }
        }
        set {
            recentSearchesSortingStrategy = newValue?.rawValue
        }
    }
}
