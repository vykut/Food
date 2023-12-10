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
        initialState: FoodListFeature.State(),
        reducer: {
            FoodListFeature()
                ._printChanges()
        }
    )

    var body: some Scene {
        WindowGroup {
            FoodList(store: store)
        }
    }
}

private enum BundleKey: DependencyKey {
    static let liveValue: Bundle = .main
}

extension DependencyValues {
    var bundle: Bundle {
        get { self[BundleKey.self] }
        set { self[BundleKey.self] = newValue }
    }
}
