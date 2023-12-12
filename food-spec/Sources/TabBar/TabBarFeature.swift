import Shared
import FoodList
import FoodSelection
import ComposableArchitecture

@Reducer
public struct TabBarFeature {
    @ObservableState
    public struct State: Equatable {
        var tab: Tab = .foodList
        var foodList: FoodListFeature.State = .init()
        var foodSelection: FoodSelectionFeature.State = .init()

        public enum Tab: Hashable {
            case foodList
            case foodComparison
        }

        public init() { }
    }

    @CasePathable
    public enum Action {
        case updateTab(State.Tab)
        case foodList(FoodListFeature.Action)
        case foodSelection(FoodSelectionFeature.Action)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.foodSelection, action: \.foodSelection) {
            FoodSelectionFeature()
        }
        Scope(state: \.foodList, action: \.foodList) {
            FoodListFeature()
        }
        Reduce { state, action in
            switch action {
                case .updateTab(let tab):
                    state.tab = tab
                    return .none
                case .foodList:
                    return .none
                case .foodSelection:
                    return .none
            }
        }
    }
}
