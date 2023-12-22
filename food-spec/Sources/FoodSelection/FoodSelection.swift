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
        var selectedFoodIds: Set<Int64?> = []
        var foodSearch: FoodSearch.State = .init()
        @Presents var foodComparison: FoodComparison.State?

        var foods: [Food] {
            foodSearch.foodObservation.foods
        }

        var searchResults: [Food] {
            foodSearch.searchResults
        }

        var isCompareButtonDisabled: Bool {
            selectedFoodIds.count < 2
        }

        var shouldShowCancelButton: Bool {
            !selectedFoodIds.isEmpty
        }

        var shouldShowPrompt: Bool {
            foodSearch.query.isEmpty && foods.isEmpty
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
                case .foodSearch(let action):
                    return .none

                case .updateSelection(let selection):
                    state.selectedFoodIds = selection
                    return .none

                case .cancelButtonTapped:
                    state.selectedFoodIds = []
                    return .none

                case .compareButtonTapped(let comparison):
                    state.foodComparison = .init(
                        foods: state.foods.filter {
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
}
