import Foundation
import Shared
import API
import FoodObservation
import ComposableArchitecture

@Reducer
public struct FoodSearch {
    @ObservableState
    public struct State: Hashable {
        public var query: String = ""
        public var isFocused: Bool = false
        public var isSearching: Bool = false
        public var foodObservation: FoodObservation.State

        public var searchResults: [Food] {
            guard shouldShowSearchResults else { return [] }
            return foodObservation.foods
                .filter {
                    $0.name.contains(query.lowercased())
                }
        }

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

        public init(foodObservation: FoodObservation.State = .init()) {
            self.foodObservation = foodObservation
        }
    }

    @CasePathable
    public enum Action {
        case updateQuery(String)
        case updateFocus(Bool)
        case searchStarted
        case searchEnded
        case searchSubmitted
        case error(Error)
        case foodObservation(FoodObservation.Action)
    }

    enum CancelID: Hashable {
        case search
    }

    public init() { }

    @Dependency(\.foodClient) private var foodClient
    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.mainQueue) private var mainQueue

    public var body: some ReducerOf<Self> {
        Scope(state: \.foodObservation, action: \.foodObservation) {
            FoodObservation()
        }
        Reduce { state, action in
            switch action {
                case .updateFocus(let focused):
                    state.isFocused = focused
                    if !focused {
                        return .cancel(id: CancelID.search)
                    } else {
                        return .none
                    }

                case .updateQuery(let query):
                    guard state.query != query else { return .none }
                    state.query = query
                    if query.isEmpty {
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

                case .error:
                    return .none

                case .searchEnded:
                    state.isSearching = false
                    return .none

                case .foodObservation:
                    return .none
            }
        }
    }

    private func startSearching(state: inout State) -> EffectOf<Self> {
        let query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
        return .concatenate(
            .send(.searchStarted),
            .run { send in
                let apiFoods = try await self.foodClient.getFoods(query: query)
                if !apiFoods.isEmpty {
                    _ = try await self.databaseClient.insert(foods: apiFoods.map(Food.init))
                }
            } catch: { error, send in
                await send(.error(error))
            }
            .debounce(id: CancelID.search, for: .milliseconds(300), scheduler: mainQueue),
            .send(.searchEnded)
        )
    }
}
