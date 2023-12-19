import Foundation
import Shared
import MealForm
import FoodDetails
import FoodComparison
import ComposableArchitecture

@Reducer 
public struct MealDetails {
    @ObservableState
    public struct State: Hashable {
        var meal: Meal
        var nutritionalValuesPerTotal: Ingredient
        var nutritionalValuesPerServing: Ingredient
        @Presents var destination: Destination.State?

        public init(meal: Meal) {
            @Dependency(\.nutritionalValuesCalculator) var calculator
            self.meal = meal
            self.nutritionalValuesPerTotal = calculator.nutritionalValues(meal: meal)
            self.nutritionalValuesPerServing = calculator.nutritionalValuesPerServing(meal: meal)
        }
    }

    @CasePathable
    public enum Action {
        case editButtonTapped
        case nutritionalInfoPerServingButtonTapped
        case nutritionalInfoButtonTapped
        case ingredientComparisonButtonTapped
        case addNotesButtonTapped
        case ingredientTapped(Ingredient)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() { }

    @Dependency(\.nutritionalValuesCalculator) private var calculator

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .editButtonTapped:
                    state.destination = .mealForm(.init(meal: state.meal))
                    return .none

                case .nutritionalInfoPerServingButtonTapped:
                    state.destination = .foodDetails(.init(
                        food: state.nutritionalValuesPerServing.food,
                        quantity: state.nutritionalValuesPerServing.quantity
                    ))
                    return .none

                case .nutritionalInfoButtonTapped:
                    state.destination = .foodDetails(.init(
                        food: state.nutritionalValuesPerTotal.food,
                        quantity: state.nutritionalValuesPerTotal.quantity
                    ))
                    return .none

                case .ingredientComparisonButtonTapped:
                    let foods = state.meal.ingredients.map(\.foodWithQuantity)
                    state.destination = .foodComparison(.init(
                        foods: foods,
                        comparison: .energy,
                        canChangeQuantity: false
                    ))
                    return .none

                case .ingredientTapped(let ingredient):
                    state.destination = .foodDetails(.init(
                        food: ingredient.food,
                        quantity: ingredient.quantity
                    ))
                    return .none

                case .addNotesButtonTapped:
                    state.destination = .mealForm(.init(meal: state.meal))
                    return .none

                case .destination(.presented(.mealForm(.delegate(.mealSaved(let meal))))):
                    state.meal = meal
                    return .none

                case .destination:
                    return .none
            }
        }
        .onChange(of: \.meal) { _, newMeal in
            Reduce { state, _ in
                state.nutritionalValuesPerTotal = calculator.nutritionalValues(meal: newMeal)
                state.nutritionalValuesPerServing = calculator.nutritionalValuesPerServing(meal: newMeal)
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
            case mealForm(MealForm.State)
            case foodDetails(FoodDetails.State)
            case foodComparison(FoodComparison.State)
        }

        @CasePathable
        public enum Action {
            case mealForm(MealForm.Action)
            case foodDetails(FoodDetails.Action)
            case foodComparison(FoodComparison.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.mealForm, action: \.mealForm) {
                MealForm()
            }
            Scope(state: \.foodDetails, action: \.foodDetails) {
                FoodDetails()
            }
            Scope(state: \.foodComparison, action: \.foodComparison) {
                FoodComparison()
            }
        }
    }
}
