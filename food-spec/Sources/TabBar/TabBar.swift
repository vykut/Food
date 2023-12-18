import Shared
import FoodList
import FoodSelection
import MealList
import ComposableArchitecture

@Reducer
public struct TabBar {
    @ObservableState
    public struct State: Equatable {
        var tab: Tab = .foodList
        var foodList: FoodList.State = .init()
        var foodSelection: FoodSelection.State = .init()
        var mealList: MealList.State = .init()

        public enum Tab: Hashable {
            case foodList
            case foodSelection
            case mealList
        }

        public init() { }
    }

    @CasePathable
    public enum Action {
        case updateTab(State.Tab)
        case foodList(FoodList.Action)
        case foodSelection(FoodSelection.Action)
        case mealList(MealList.Action)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.foodSelection, action: \.foodSelection) {
            FoodSelection()
        }
        Scope(state: \.foodList, action: \.foodList) {
            FoodList()
        }
        Scope(state: \.mealList, action: \.mealList) {
            MealList()
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
                case .mealList:
                    return .none
            }
        }
    }
}
