import Shared
import FoodList
import FoodSelection
import MealList
import Spotlight
import ComposableArchitecture

@Reducer
public struct TabBar: Sendable {
    @ObservableState
    public struct State: Equatable {
        var tab: Tab = .foodList
        var foodList: FoodList.State = .init()
        var foodSelection: FoodSelection.State = .init()
        var mealList: MealList.State = .init()
        var spotlight: SpotlightReducer.State = .init()

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
        case spotlight(SpotlightReducer.Action)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.foodSelection, action: \.foodSelection) {
            FoodSelection()
        }
        Scope(state: \.mealList, action: \.mealList) {
            MealList()
        }
        Scope(state: \.foodList, action: \.foodList) {
            FoodList()
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
                case .spotlight(.delegate(let action)):
                    return reduce(state: &state, action: action)
                case .spotlight:
                    return .none
            }
        }
        Scope(state: \.spotlight, action: \.spotlight) {
            SpotlightReducer()
        }
    }

    private func reduce(state: inout State, action: SpotlightReducer.Action.Delegate) -> EffectOf<Self> {
        switch action {
            case .showFoodDetails(let food):
                state.tab = .foodList
                state.foodList.destination = .foodDetails(.init(food: food))
                return .none

            case .showMealDetails(let meal):
                state.tab = .mealList
                state.mealList.destination = .mealDetails(.init(meal: meal))
                return .none

            case .searchFood(let query):
                state.tab = .foodList
                state.foodList.destination = nil
                state.foodList.foodSearch.isFocused = true
                return .send(.foodList(.foodSearch(.updateQuery(query))))
        }
    }
}
