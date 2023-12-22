import Foundation
import Shared
import Database
import FoodComparison
import Search
import ComposableArchitecture

@Reducer
public struct FoodSelection {
    @ObservableState
    public struct State: Hashable {
        var foods: [Food] = []
        var selectedFoodIds: Set<Int64?> = []
        var foodSearch: FoodSearch.State = .init()
        @Presents var foodComparison: FoodComparison.State?

        var filteredFoods: [Food] {
            guard !foodSearch.query.isEmpty else { return foods }
            return foods.filter {
                $0.name.range(of: foodSearch.query, options: .caseInsensitive) != nil
            }
        }

        var isCompareButtonDisabled: Bool {
            selectedFoodIds.count < 2
        }

        var shouldShowCancelButton: Bool {
            !selectedFoodIds.isEmpty
        }

        func isSelectionDisabled(for food: Food) -> Bool {
            selectedFoodIds.count >= 7 &&
            !selectedFoodIds.contains(food.id)
        }

        public init(selectedFoodIds: Set<Int64?> = []) {
            self.selectedFoodIds = selectedFoodIds
        }
    }

    @CasePathable
    public enum Action {
        case foodSearch(FoodSearch.Action)
        case onFirstAppear
        case updateFoods([Food])
        case updateSelection(Set<Int64?>)
        case foodComparison(PresentationAction<FoodComparison.Action>)
        case cancelButtonTapped
        case compareButtonTapped(Comparison)
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Scope(state: \.foodSearch, action: \.foodSearch) {
            FoodSearch()
        }
        Reduce { state, action in
            switch action {
                case .onFirstAppear:
                    return .run { [databaseClient] send in
                        let observation = databaseClient.observeFoods(sortedBy: Column("name"), order: .forward)
                        for await foods in observation {
                            await send(.updateFoods(foods))
                        }
                    }

                case .foodSearch(let action):
                    return reduce(state: &state, action: action)

                case .updateFoods(let foods):
                    state.foods = foods
                    return .none

                case .updateSelection(let selection):
                    state.selectedFoodIds = selection
                    return .none

                case .cancelButtonTapped:
                    state.selectedFoodIds = []
                    return .none

                case .compareButtonTapped(let comparison):
                    state.foodComparison = .init(
                        foods: state.filteredFoods.filter {
                            state.selectedFoodIds.contains($0.id)
                        },
                        comparison: comparison,
                        foodSortingStrategy: .value,
                        foodSortingOrder: .forward
                    )
                    return .none

                case .foodComparison:
                    return .none
            }
        }
        .ifLet(\.$foodComparison, action: \.foodComparison) {
            FoodComparison()
        }
    }

    private func reduce(state: inout State, action: FoodSearch.Action) -> EffectOf<Self> {
        switch action {
            case .updateQuery(let query):
                return .none

            case .updateFocus(let focused):
                return .none

            case .searchStarted:
                return .none

            case .searchEnded:
                return .none

            case .searchSubmitted:
                return .none

            case .result(let foods):
                return .none

            case .error(let error):
                return .none
        }
    }
}
