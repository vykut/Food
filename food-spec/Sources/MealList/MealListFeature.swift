import Foundation
import Shared
import Database
import ComposableArchitecture

@Reducer
public struct MealListFeature {
    @ObservableState
    public struct State: Hashable {
        var meals: [Meal] = []

        public init() { }
    }

    @CasePathable
    public enum Action {
        case plusButtonTapped
        case onTask
        case onMealsUpdate([Meal])
        case onDelete(IndexSet)
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                    // FIXME: Remove this
                case .plusButtonTapped:
                    return .run { [databaseClient] send in
                        _ = try await databaseClient.insert(
                            meal: .init(
                                name: Date().formatted(),
                                ingredients: [
                                    .init(food: .preview, quantity: .grams(100)),
                                    .init(food: .preview, quantity: .grams(200)),
                                    .init(food: .preview, quantity: .init(value: 15, unit: .pounds)),
                                ],
                                instructions: "empty"
                            ))
                    }
                case .onTask:
                    return .run { [databaseClient] send in
                        let stream = databaseClient.observeMeals()
                        for await meals in stream {
                            await send(.onMealsUpdate(meals), animation: .default)
                        }
                    }

                case .onMealsUpdate(let meals):
                    state.meals = meals
                    // handle empty meals
                    return .none

                case .onDelete(let indices):
                    return .run { [meals = state.meals, databaseClient] send in
                        let mealsToDelete = indices.map { meals[$0] }
                        for meal in mealsToDelete {
                            try await databaseClient.delete(meal: meal)
                        }
                    }
            }
        }
    }
}
