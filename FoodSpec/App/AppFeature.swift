//
//  AppFeature.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 11/12/2023.
//

import Foundation
import ComposableArchitecture

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
