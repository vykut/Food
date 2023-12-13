import Foundation
import Shared
import Database
import FoodComparison
import ComposableArchitecture

@Reducer
public struct FoodSelectionFeature {
    @ObservableState
    public struct State: Hashable {
        var foods: [Food] = []
        var selectedFoodIds: Set<Int64?> = []
        var filterQuery: String = ""
        @Presents var foodComparison: FoodComparisonFeature.State?

        var filteredFoods: [Food] {
            guard !filterQuery.isEmpty else { return foods }
            return foods.filter {
                $0.name.range(of: filterQuery, options: .caseInsensitive) != nil
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
        case onTask
        case updateFoods([Food])
        case updateSelection(Set<Int64?>)
        case updateFilter(String)
        case foodComparison(PresentationAction<FoodComparisonFeature.Action>)
        case cancelButtonTapped
        case compareButtonTapped(Comparison)
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onTask:
                    return .run { [databaseClient] send in
                        let observation = databaseClient.observeFoods(sortedBy: Food.Columns.name, order: .forward)
                        for await foods in observation {
                            await send(.updateFoods(foods))
                        }
                    }

                case .updateFoods(let foods):
                    state.foods = foods
                    return .none

                case .updateSelection(let selection):
                    state.selectedFoodIds = selection
                    return .none

                case .updateFilter(let query):
                    state.filterQuery = query
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
            FoodComparisonFeature()
        }
    }
}
