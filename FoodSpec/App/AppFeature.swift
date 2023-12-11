import Foundation
import ComposableArchitecture
import FoodList

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var foodList: FoodListFeature.State = .init()
    }

    @CasePathable
    enum Action {
        case foodList(FoodListFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.foodList, action: \.foodList) {
            FoodListFeature()
        }
        Reduce { state, action in
            switch action {
                case .foodList:
                    return .none
            }
        }
    }
}
