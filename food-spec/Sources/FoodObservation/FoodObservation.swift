import Foundation
import Database
import Shared
import ComposableArchitecture

@Reducer
public struct FoodObservation {
    @ObservableState
    public struct State: Hashable {
        public var foods: [Food] = []
        public var sortStrategy: SortStrategy
        public var sortOrder: SortOrder

        public init(
            sortStrategy: SortStrategy = .name,
            sortOrder: SortOrder = .forward
        ) {
            self.sortStrategy = sortStrategy
            self.sortOrder = sortOrder
        }

        public enum SortStrategy: String, Codable, Identifiable, Hashable, CaseIterable, Sendable {
            case name
            case energy
            case carbohydrate
            case protein
            case fat

            public var id: Self { self }

            var column: Column {
                switch self {
                    case .name: Column("name")
                    case .energy: Column("energy")
                    case .carbohydrate: Column("carbohydrate")
                    case .protein: Column("protein")
                    case .fat: Column("fatTotal")
                }
            }
        }
    }

    @CasePathable
    public enum Action {
        case startObservation
        case updateFoods([Food])
        case updateSortStrategy(State.SortStrategy, SortOrder)
    }

    private let cancelId = UUID()

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .startObservation:
                    return observationEffect(strategy: state.sortStrategy, order: state.sortOrder)

                case .updateFoods(let foods):
                    state.foods = foods
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
                        return observationEffect(strategy: state.sortStrategy, order: state.sortOrder)
                    } else {
                        return .none
                    }
            }
        }
    }

    private func observationEffect(strategy: State.SortStrategy, order: SortOrder) -> EffectOf<Self> {
        .concatenate(
            .cancel(id: cancelId),
            .run { send in
                let observation = databaseClient.observeFoods(sortedBy: strategy.column, order: order)
                for await foods in observation {
                    await send(.updateFoods(foods))
                }
                print("Finished", Task.isCancelled)
            }
            .cancellable(id: cancelId, cancelInFlight: true)
        )
    }
}
