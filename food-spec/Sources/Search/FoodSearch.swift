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

        public var shouldShowSearchResults: Bool {
            isFocused &&
            !query.isEmpty
        }

        public var shouldShowNoResults: Bool {
            shouldShowSearchResults &&
            !isSearching &&
            hasNoResults
        }

        public var hasNoResults: Bool {
            searchResults.isEmpty
        }

        public init() { }
    }

    @CasePathable
    public enum Action {
        case updateQuery(String)
        case updateFocus(Bool)
        case searchStarted
        case searchEnded
        case searchSubmitted
        case result([Food])
        case error(Error)
    }

    enum CancelID: Hashable {
        case search
    }

    public init() { }

    @Dependency(\.foodClient) private var foodClient
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.mainQueue) private var mainQueue

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .updateFocus(let focused):
                    state.isFocused = focused
                    if !focused {
                        state.searchResults = []
                        return .cancel(id: CancelID.search)
                    } else {
                        return .none
                    }

                case .updateQuery(let query):
                    guard state.query != query else { return .none }
                    state.query = query
                    if query.isEmpty {
                        state.searchResults = []
                        return .cancel(id: CancelID.search)
                    } else {
                        return .concatenate(
                            .cancel(id: CancelID.search),
                            startSearching(state: &state)
                        )
                    }

                case .searchSubmitted:
                    return startSearching(state: &state)

                case .searchStarted:
                    state.isSearching = true
                    return .none

                case .result(let foods):
                    guard state.isSearching else { return .none }
                    state.searchResults = foods
                    return .none

                case .error:
                    return .none

                case .searchEnded:
                    state.isSearching = false
                    return .none
            }
        }
    }

    private func startSearching(state: inout State) -> EffectOf<Self> {
        let query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
        func getFoods() async throws -> [Food] {
            try await self.databaseClient.getFoods(
                matching: query,
                sortedBy: Column("name"),
                order: .forward
            )
        }
        return .concatenate(
            .send(.searchStarted),
            .run { send in
                if try await self.databaseClient.numberOfFoods(matching: query) != 0 {
                    try await send(.result(getFoods()), animation: .default)
                } else {
                    await send(.result([]), animation: .default)
                }
            },
            .run { send in
                let apiFoods = try await self.foodClient.getFoods(query: query)
                if !apiFoods.isEmpty {
                    _ = try await self.databaseClient.insert(foods: apiFoods.map(Food.init))
                    try await send(.result(getFoods()), animation: .default)
                }
            } catch: { error, send in
                await send(.error(error))
            }
            .debounce(id: CancelID.search, for: .milliseconds(300), scheduler: mainQueue),
            .send(.searchEnded)
        )
    }
}
