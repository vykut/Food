import Foundation
import Shared
import Search
import FoodObservation
import ComposableArchitecture

@Reducer
public struct SearchableFoodList {
    @ObservableState
    public struct State: Hashable {
        public var foodObservation: FoodObservation.State = .init()
        public var foodSearch: FoodSearch.State = .init()
        @Presents var alert: AlertState<Action.Alert>?

        public var foods: [Food] {
            foodObservation.foods
        }

        public var searchResults: [Food] {
            foodSearch.searchResults
        }

        public var query: String {
            foodSearch.query
        }

        public init(
            sortStrategy: Food.SortStrategy = .name,
            sortOrder: SortOrder = .forward
        ) {
            self.foodObservation = .init(
                sortStrategy: sortStrategy,
                sortOrder: sortOrder
            )
            self.foodSearch = .init(
                sortStrategy: sortStrategy,
                sortOrder: sortOrder
            )
        }
    }

    @CasePathable
    public enum Action {
        case foodSearch(FoodSearch.Action)
        case foodObservation(FoodObservation.Action)
        case updateSortStrategy(Food.SortStrategy, SortOrder)
        case alert(PresentationAction<Alert>)

        public enum Alert: Hashable { }
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.foodObservation, action: \.foodObservation) {
            FoodObservation()
        }
        Scope(state: \.foodSearch, action: \.foodSearch) {
            FoodSearch()
        }
        Reduce { state, action in
            switch action {
                case .foodSearch(.error):
                    if state.foodSearch.hasNoResults {
                        state.alert = AlertState {
                            TextState("Something went wrong. Please try again later.")
                        }
                    }
                    return .none

                case .foodSearch:
                    return .none

                case .foodObservation:
                    return .none

                case .updateSortStrategy(let strategy, let order):
                    return .merge(
                        .send(.foodSearch(.updateSortStrategy(strategy, order))),
                        .send(.foodObservation(.updateSortStrategy(strategy, order)))
                    )

                case .alert:
                    return .none
            }
        }
    }
}
