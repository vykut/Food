import Foundation
import Shared
import ComposableArchitecture

@Reducer
public struct RecipeCalculatorFeature {
    @ObservableState
    public struct State: Hashable {

        public init() { }
    }

    @CasePathable
    public enum Action {

    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
