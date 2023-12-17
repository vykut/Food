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
        var mealsWithNutritionalValues: [MealWithNutritionalValues] = []
        @Presents var destination: Destination.State?

        var showsAddMealPrompt: Bool {
            mealsWithNutritionalValues.isEmpty
        }

        struct MealWithNutritionalValues: Hashable {
            let meal: Meal
            let perTotal: Ingredient
            let perServing: Ingredient
        }

        public init() { }
    }

    @CasePathable
    public enum Action {
        case onFirstAppear
        case plusButtonTapped
        case onMealsUpdate([Meal])
        case mealTapped(Meal)
        case onDelete(IndexSet)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.nutritionalValuesCalculator) private var calculator

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
                    state.mealsWithNutritionalValues = meals.map {
                        .init(
                            meal: $0,
                            perTotal: calculator.nutritionalValues(meal: $0),
                            perServing: calculator.nutritionalValuesPerServing(meal: $0)
                        )
                    }
                    return .none

                case .plusButtonTapped:
                    state.destination = .mealForm(.init())
                    return .none

                case .mealTapped(let meal):
                    state.destination = .mealDetails(.init(meal: meal))
                    return .none

                case .onDelete(let indices):
                    return .run { [nutritionalValues = state.mealsWithNutritionalValues, databaseClient] send in
                        let mealsToDelete = indices.map { nutritionalValues[$0].meal }
                        for meal in mealsToDelete {
                            try await databaseClient.delete(meal: meal)
                        }
                    }

                case .destination:
                    return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }

    @Reducer
    public struct Destination {
        @ObservableState
        public enum State: Hashable {
            case mealDetails(MealDetailsFeature.State)
            case mealForm(MealFormFeature.State)
        }

        @CasePathable
        public enum Action {
            case mealDetails(MealDetailsFeature.Action)
            case mealForm(MealFormFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.mealDetails, action: \.mealDetails) {
                MealDetailsFeature()
            }
            Scope(state: \.mealForm, action: \.mealForm) {
                MealFormFeature()
            }
        }
    }
}
