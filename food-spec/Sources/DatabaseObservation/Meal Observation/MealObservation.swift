import Foundation
import Database
import Shared
import ComposableArchitecture

@Reducer
public struct MealObservation: Sendable {
    @ObservableState
    public struct State: Hashable {
        fileprivate let observationId: UUID
        public var meals: [Meal] = []
        public var sortStrategy: Meal.SortStrategy
        public var sortOrder: SortOrder

        public init(
            sortStrategy: Meal.SortStrategy = .name,
            sortOrder: SortOrder = .forward
        ) {
            @Dependency(\.uuid) var uuid
            self.observationId = uuid()
            self.sortStrategy = sortStrategy
            self.sortOrder = sortOrder
        }
    }

    @CasePathable
    public enum Action {
        case startObservation
        case updateMeals([Meal])
        case updateSortStrategy(Meal.SortStrategy, SortOrder)
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .startObservation:
                    return observationEffect(state: state)

                case .updateMeals(let meals):
                    state.meals = meals
                    return .none

                case .updateSortStrategy(let strategy, let order):
                    var shouldRestartObservation = false
                    if strategy != state.sortStrategy {
                        state.sortStrategy = strategy
                        shouldRestartObservation = true
                    }
                    if order != state.sortOrder {
                        state.sortOrder = order
                        shouldRestartObservation = true
                    }
                    if shouldRestartObservation {
                        return observationEffect(state: state)
                    } else {
                        return .none
                    }
            }
        }
    }

    private func observationEffect(state: State) -> EffectOf<Self> {
        .run { send in
            let observation = databaseClient.observeMeals(sortedBy: state.sortStrategy, order: state.sortOrder)
            for await foods in observation {
                await send(.updateMeals(foods), animation: .default)
            }
        }
        .cancellable(id: state.observationId, cancelInFlight: true)
    }
}

