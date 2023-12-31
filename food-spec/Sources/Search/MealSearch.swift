import Foundation
import Shared
import Database
import ComposableArchitecture

@Reducer
public struct MealSearch: Sendable {
    @ObservableState
    public struct State: Hashable {
        public var query: String = ""
        public var isFocused: Bool = false
        public var isSearching: Bool = false
        public var searchResults: [Meal] = []
        public var sortStrategy: Meal.SortStrategy
        public var sortOrder: SortOrder
        @Presents public var alert: AlertState<Action.Alert>?

        public var hasNoResults: Bool {
            searchResults.isEmpty
        }

        public var shouldShowNoResults: Bool {
            shouldShowSearchResults &&
            !isSearching &&
            hasNoResults
        }

        public var shouldShowSearchResults: Bool {
            isFocused &&
            !query.isEmpty
        }

        public init(
            sortStrategy: Meal.SortStrategy = .name,
            sortOrder: SortOrder = .forward
        ) {
            self.sortStrategy = sortStrategy
            self.sortOrder = sortOrder
        }
    }

    @CasePathable
    public enum Action {
        case updateQuery(String)
        case updateFocus(Bool)
        case updateSortStrategy(Meal.SortStrategy, SortOrder)
        case searchStarted
        case searchEnded
        case searchSubmitted
        case result([Meal])
        case error(Error)
        case alert(PresentationAction<Alert>)

        @CasePathable
        public enum Alert: Hashable { }
    }

    enum CancelID: Hashable {
        case search
        case apiSearch
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.continuousClock) private var clock

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .updateFocus(let focused):
                    state.isFocused = focused
                    if !focused {
                        state.searchResults = []
                        return .cancel(id: CancelID.apiSearch)
                    } else {
                        return .none
                    }

                case .updateQuery(let query):
                    guard state.query != query else { return .none }
                    state.query = query
                    if query.isEmpty {
                        state.searchResults = []
                        return .cancel(id: CancelID.apiSearch)
                    } else {
                        return startSearching(state: state)
                    }

                case .searchSubmitted:
                    return startSearching(state: state)

                case .searchStarted:
                    guard !state.isSearching else { return .none }
                    state.isSearching = true
                    return .none

                case .result(let foods):
                    state.searchResults = foods
                    return .none

                case .error:
                    if state.hasNoResults {
                        state.alert = AlertState {
                            TextState("Something went wrong. Please try again later.")
                        }
                    }
                    return .none

                case .alert:
                    return .none

                case .searchEnded:
                    guard state.isSearching else { return .none }
                    state.isSearching = false
                    return .none

                case .updateSortStrategy(let strategy, let order):
                    state.sortStrategy = strategy
                    state.sortOrder = order
                    return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func startSearching(state: State) -> EffectOf<Self> {
        let query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
        return .concatenate(
            .send(.searchStarted),
            .run { send in
                try await send(.result(self.getMeals(state: state)))
            } catch: { error, send in
                await send(.error(error))
            }
            .cancellable(id: CancelID.apiSearch, cancelInFlight: true),
            .send(.searchEnded)
        )
        .cancellable(id: CancelID.search, cancelInFlight: true)
    }

    private func getMeals(state: State) async throws -> [Meal] {
        let query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
        return try await databaseClient.getMeals(
            matching: query,
            sortedBy: state.sortStrategy,
            order: state.sortOrder
        )
    }
}

