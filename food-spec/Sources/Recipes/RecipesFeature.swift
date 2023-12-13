import Foundation
import Shared
import Database
import ComposableArchitecture

@Reducer
public struct RecipesFeature {
    @ObservableState
    public struct State: Hashable {

        public init() { }
    }

    @CasePathable
    public enum Action {

    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
