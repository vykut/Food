//
//  FoodDetailsFeature.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 02/12/2023.
//

import Foundation
import ComposableArchitecture
import Shared

@Reducer
struct FoodDetailsFeature {
    @ObservableState
    struct State: Hashable {
        let food: Food
    }

    @CasePathable
    enum Action {

    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
