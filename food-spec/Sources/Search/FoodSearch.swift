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
        fileprivate var isActuallySearching: Bool = false
        public var isSearching: Bool = false

        public init() { }
    }

    @CasePathable
    public enum Action {
        case updateQuery(String)
        case updateFocus(Bool)
        case searchStarted
        case actualSearchStarted
        case searchEnded
        case searchSubmitted
        case delegate(Delegate)

        @CasePathable
        public enum Delegate {
            case searchStarted
            case searchEnded
            case result([Food])
            case error(Error)
        }
    }

    enum CancelID: Hashable {
        case search
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
                        return .cancel(id: CancelID.search)
                    } else {
                        return .none
                    }

                case .updateQuery(let query):
                    guard state.query != query else { return .none }
                    state.query = query
                    guard !query.isEmpty else { return .cancel(id: CancelID.search) }
                    return .concatenate(
                        .cancel(id: CancelID.search),
                        startSearching(state: &state)
                    )

                case .searchSubmitted:
                    return startSearching(state: &state)

                case .searchStarted:
                    guard !state.isSearching else { return .none }
                    state.isSearching = true
                    return .send(.delegate(.searchStarted))
//                    return .none

                case .actualSearchStarted:
                    state.isActuallySearching = true
                    return .none

                case .searchEnded:
//                    guard state.isActuallySearching else { return .none }
                    guard state.isSearching else { return .none }
                    state.isActuallySearching = false
                    state.isSearching = false
                    return .send(.delegate(.searchEnded))
//                    return .none

                case .delegate:
                    return .none
            }
        }
    }

    private func startSearching(state: inout State) -> EffectOf<Self> {
//        .run { [query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)] send in
//            func getFoods() async throws -> [Food] {
//                try await self.databaseClient.getFoods(
//                    matching: query,
//                    sortedBy: Column("name"),
//                    order: .forward
//                )
//            }
//            await send(.searchStarted)
//            if try await self.databaseClient.numberOfFoods(matching: query) != 0 {
//                try await send(.delegate(.result(getFoods())), animation: .default)
//            } else {
//                await send(.delegate(.result([])), animation: .default)
//            }
//            do {
//                try await withTaskCancellation(id: CancelID.search, cancelInFlight: true) {
//                    try await self.clock.sleep(for: .milliseconds(300))
//                    do {
//                        let apiFoods = try await self.foodClient.getFoods(query: query)
//                        if !apiFoods.isEmpty {
//                            _ = try await self.databaseClient.insert(foods: apiFoods.map(Food.init))
//                            try await send(.delegate(.result(getFoods())), animation: .default)
//                        }
//                    } catch {
//                        try Task.checkCancellation()
//                        throw error
//                    }
//                }
//            } catch is CancellationError {
//                // do nothing
//            } catch {
//                await send(.delegate(.error(error)))
//            }
//            await send(.searchEnded)
//        }

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
                    try await send(.delegate(.result(getFoods())), animation: .default)
                } else {
                    await send(.delegate(.result([])), animation: .default)
                }
            },
            .run { send in
                let apiFoods = try await self.foodClient.getFoods(query: query)
                if !apiFoods.isEmpty {
                    _ = try await self.databaseClient.insert(foods: apiFoods.map(Food.init))
                    try await send(.delegate(.result(getFoods())), animation: .default)
                }
            } catch: { error, send in
                await send(.delegate(.error(error)))
            }
            .debounce(id: CancelID.search, for: .milliseconds(300), scheduler: mainQueue),
            .send(.searchEnded)
        )
//        return .run { [query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)] send in
//            await send(.searchStarted)
//            if try await self.databaseClient.numberOfFoods(matching: query) != 0 {
//                try await send(.delegate(.result(getFoods())), animation: .default)
//            } else {
//                await send(.delegate(.result([])), animation: .default)
//            }
//            do {
//                try await withTaskCancellation(id: CancelID.search, cancelInFlight: true) {
//                    try await self.clock.sleep(for: .milliseconds(300))
//                    do {
//                        let apiFoods = try await self.foodClient.getFoods(query: query)
//                        if !apiFoods.isEmpty {
//                            _ = try await self.databaseClient.insert(foods: apiFoods.map(Food.init))
//                            try await send(.delegate(.result(getFoods())), animation: .default)
//                        }
//                    } catch {
//                        try Task.checkCancellation()
//                        throw error
//                    }
//                }
//            } catch is CancellationError {
//                // do nothing
//            } catch {
//                await send(.delegate(.error(error)))
//            }
//            await send(.searchEnded)
//        }
    }
}
