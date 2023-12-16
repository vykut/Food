import Foundation
import Shared
import Database
import MealForm
import MealDetails
import ComposableArchitecture

@Reducer
public struct MealListFeature {
    @ObservableState
    public struct State: Hashable {
        var meals: [Meal] = []
        @Presents var mealDetails: MealDetailsFeature.State?
        @Presents var mealForm: MealFormFeature.State?

        public init() { }
    }

    @CasePathable
    public enum Action {
        case plusButtonTapped
        case onFirstAppear
        case onMealsUpdate([Meal])
        case mealTapped(Meal)
        case onDelete(IndexSet)
        case mealDetails(PresentationAction<MealDetailsFeature.Action>)
        case mealForm(PresentationAction<MealFormFeature.Action>)
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onFirstAppear:
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

                case .plusButtonTapped:
                    state.mealForm = .init()
                    return .none

                case .mealTapped(let meal):
                    state.mealDetails = .init(meal: meal)
                    return .none

                case .onDelete(let indices):
                    return .run { [meals = state.meals, databaseClient] send in
                        let mealsToDelete = indices.map { meals[$0] }
                        for meal in mealsToDelete {
                            try await databaseClient.delete(meal: meal)
                        }
                    }

                case .mealDetails:
                    return .none

                case .mealForm:
                    return .none
            }
        }
        .ifLet(\.$mealDetails, action: \.mealDetails) {
            MealDetailsFeature()
        }
        .ifLet(\.$mealForm, action: \.mealForm) {
            MealFormFeature()
        }
    }
}
