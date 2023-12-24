import Foundation
import Shared
import Database
import MealForm
import MealDetails
import DatabaseObservation
import Search
import ComposableArchitecture

@Reducer
public struct MealList: Sendable {
    @ObservableState
    public struct State: Hashable {
        var mealsWithNutritionalValues: [MealWithNutritionalValues] = []
        var searchResults: [MealWithNutritionalValues] = []
        var mealObservation: MealObservation.State = .init()
        var mealSearch: MealSearch.State = .init()
        @Presents public var destination: Destination.State?

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
        case plusButtonTapped
        case mealTapped(Meal)
        case onDelete(IndexSet)
        case mealObservation(MealObservation.Action)
        case mealSearch(MealSearch.Action)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient
    @Dependency(\.nutritionalValuesCalculator) private var calculator

    public var body: some ReducerOf<Self> {
        Scope(state: \.mealObservation, action: \.mealObservation) {
            MealObservation()
        }
        Scope(state: \.mealSearch, action: \.mealSearch) {
            MealSearch()
        }
        Reduce { state, action in
            switch action {
                case .mealObservation(.updateMeals(let meals)):
                    state.mealsWithNutritionalValues = meals.map {
                        .init(
                            meal: $0,
                            perTotal: calculator.nutritionalValues(meal: $0),
                            perServing: calculator.nutritionalValuesPerServing(meal: $0)
                        )
                    }
                    return .none

                case .mealSearch(.result(let meals)):
                    state.searchResults = meals.map {
                        .init(
                            meal: $0,
                            perTotal: calculator.nutritionalValues(meal: $0),
                            perServing: calculator.nutritionalValuesPerServing(meal: $0)
                        )
                    }
                    return .none

                case .mealSearch(.updateFocus(let focused)):
                    if !focused {
                        state.searchResults = []
                    }
                    return .none

                case .mealSearch(.updateQuery(let query)):
                    if query.isEmpty {
                        state.searchResults = []
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
                        try await databaseClient.delete(meals: mealsToDelete)
                    }

                case .destination(.presented(.mealForm(.delegate(.mealSaved(let meal))))):
                    state.destination = .mealDetails(.init(meal: meal))
                    return .none

                case .destination:
                    return .none

                case .mealObservation:
                    return .none

                case .mealSearch:
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
            case mealDetails(MealDetails.State)
            case mealForm(MealForm.State)
        }

        @CasePathable
        public enum Action {
            case mealDetails(MealDetails.Action)
            case mealForm(MealForm.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.mealDetails, action: \.mealDetails) {
                MealDetails()
            }
            Scope(state: \.mealForm, action: \.mealForm) {
                MealForm()
            }
        }
    }
}
