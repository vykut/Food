//
//  FoodSpecApp.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct FoodSpecApp: App {
    let store = Store(
        initialState: FoodListReducer.State(),
        reducer: {
            FoodListReducer()
        }
    )

    var body: some Scene {
        WindowGroup {
            FoodList(store: store)
        }
    }
}

extension FoodClient: EnvironmentKey {
    public static let defaultValue: Self = .init()
}

extension EnvironmentValues {
    var foodClient: FoodClient {
        get {
            self[FoodClient.self]
        }
        set {
            self[FoodClient.self] = newValue
        }
    }
}
