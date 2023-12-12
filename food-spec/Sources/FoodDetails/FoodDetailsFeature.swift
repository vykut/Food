import Foundation
import ComposableArchitecture
import Shared
import NutritionalValuePicker

@Reducer
public struct FoodDetailsFeature {
    @ObservableState
    public struct State: Hashable {
        var food: Food
        var nutritionalValuePicker: NutritionalValuePickerFeature.State = .init()

        public init(food: Food) {
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
                case .nutritionalValuePicker:
                    return .none
            }
        }
    }
}
