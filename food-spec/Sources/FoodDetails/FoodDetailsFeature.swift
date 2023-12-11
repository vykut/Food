import Foundation
import ComposableArchitecture
import Shared

@Reducer
public struct FoodDetailsFeature {
    @ObservableState
    public struct State: Hashable {
        let food: Food

        public init(food: Food) {
            self.food = food
        }
    }

    @CasePathable
    public enum Action {

    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
