import Foundation
import Shared
import MealForm
import FoodDetails
import FoodComparison
import ComposableArchitecture

@Reducer 
public struct MealDetailsFeature {
    @ObservableState
    public struct State: Hashable {
        var meal: Meal
        @Presents var mealForm: MealFormFeature.State?
        @Presents var foodDetails: FoodDetailsFeature.State?
        @Presents var foodComparison: FoodComparisonFeature.State?

        public init(meal: Meal) {
            self.meal = meal
        }
    }

    @CasePathable
    public enum Action {
        case editButtonTapped
        case nutritionalInfoPerServingSizeButtonTapped
        case ingredientComparisonButtonTapped
        case ingredientTapped(Ingredient)
        case mealForm(PresentationAction<MealFormFeature.Action>)
        case foodDetails(PresentationAction<FoodDetailsFeature.Action>)
        case foodComparison(PresentationAction<FoodComparisonFeature.Action>)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .editButtonTapped:
                    state.mealForm = .init(meal: state.meal)
                    return .none
                case .nutritionalInfoPerServingSizeButtonTapped:
                    let nutritionalInfoPerServingSize = state.meal.nutritionalValuesPerServingSize
                    state.foodDetails = .init(
                        food: nutritionalInfoPerServingSize.food,
                        quantity: nutritionalInfoPerServingSize.quantity
                    )
                    return .none
                case .ingredientComparisonButtonTapped:
                    let foods = state.meal.ingredients.map(\.foodWithQuantity)
                    state.foodComparison = .init(
                        foods: foods,
                        comparison: .energy,
                        canChangeQuantity: false
                    )
                    return .none

                case .ingredientTapped(let ingredient):
                    state.foodDetails = .init(
                        food: ingredient.food,
                        quantity: ingredient.quantity
                    )
                    return .none

                case .mealForm(.dismiss):
                    if let meal = state.mealForm?.meal {
                        state.meal = meal
                    }
                    return .none

                case .mealForm:
                    return .none

                case .foodDetails:
                    return .none

                case .foodComparison:
                    return .none
            }
        }
        .ifLet(\.$mealForm, action: \.mealForm) {
            MealFormFeature()
        }
        .ifLet(\.$foodDetails, action: \.foodDetails) {
            FoodDetailsFeature()
        }
        .ifLet(\.$foodComparison, action: \.foodComparison) {
            FoodComparisonFeature()
        }
    }
}
