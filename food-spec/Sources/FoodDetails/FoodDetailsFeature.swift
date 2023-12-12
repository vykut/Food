import Foundation
import ComposableArchitecture
import Shared
import NutritionalValuePicker

@Reducer
public struct FoodDetailsFeature {
    @ObservableState
    public struct State: Hashable {
        let originalFood: Food
        var food: Food
        var nutritionalValuePicker: NutritionalValuePickerFeature.State = .init()

        public init(food: Food) {
            self.originalFood = food
            self.food = food
        }
    }

    @CasePathable
    public enum Action {
        case nutritionalValuePicker(NutritionalValuePickerFeature.Action)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.nutritionalValuePicker, action: \.nutritionalValuePicker) {
            NutritionalValuePickerFeature()
        }
        Reduce { state, action in
            switch action {
                case .nutritionalValuePicker(let action):
                    return reduce(state: &state, action: action)
            }
        }
    }

    private func reduce(state: inout State, action: NutritionalValuePickerFeature.Action) -> Effect<Action> {
        state.food = state.originalFood.changeServingSize(to: state.nutritionalValuePicker.quantity)
        return .none
    }
}

extension Food {
    func changeServingSize(to quantity: Quantity) -> Self {
        let quantityInGrams = quantity.converted(to: .grams)
        let ratio = quantityInGrams.value / 100

        return  .init(
            id: nil,
            name: self.name,
            energy: self.energy * ratio,
            fatTotal: self.fatTotal * ratio,
            fatSaturated: self.fatSaturated * ratio,
            protein: self.protein * ratio,
            sodium: self.sodium * ratio,
            potassium: self.potassium * ratio,
            cholesterol: self.cholesterol * ratio,
            carbohydrate: self.carbohydrate * ratio,
            fiber: self.fiber * ratio,
            sugar: self.sugar * ratio
        )
    }
}
