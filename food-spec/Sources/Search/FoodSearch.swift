import Foundation
import Shared
import API
import Database
import ComposableArchitecture

@Reducer
public struct FoodSearch {
    @ObservableState
    public struct State: Hashable {
        public var query: String = ""
        public var isFocused: Bool = false
        public var isSearching: Bool = false
        public var searchResults: [Food] = []
        public var sortStrategy: Food.SortStrategy
        public var sortOrder: SortOrder

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
            sortStrategy: Food.SortStrategy = .name,
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
        case updateSortStrategy(Food.SortStrategy, SortOrder)
        case searchStarted
        case searchEnded
        case searchSubmitted
        case result([Food])
        case error(Error)
    }

    enum CancelID: Hashable {
        case search
        case apiSearch
    }

    public init() { }

    @Dependency(\.foodClient) private var foodClient
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.mainQueue) private var mainQueue
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
    }

    private func startSearching(state: State) -> EffectOf<Self> {
        let query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
        return .concatenate(
            .send(.searchStarted),
            .run { send in
                try await send(.result(self.getFoods(state: state)))
                try await clock.sleep(for: .milliseconds(300))
                let apiFoods = try await self.foodClient.getFoods(query: query)
                if !apiFoods.isEmpty {
                    _ = try await self.databaseClient.insert(foods: apiFoods.map(Food.init))
                }
                try await send(.result(self.getFoods(state: state)))
            } catch: { error, send in
                await send(.error(error))
            }
            .cancellable(id: CancelID.apiSearch, cancelInFlight: true),
            .send(.searchEnded)
        )
        .cancellable(id: CancelID.search, cancelInFlight: true)
    }

    private func getFoods(state: State) async throws -> [Food] {
        let query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
        return try await databaseClient.getFoods(
            matching: query,
            sortedBy: state.sortStrategy,
            order: state.sortOrder
        )
    }
}
