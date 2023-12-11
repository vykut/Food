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
    @State var store = Store(
        initialState: AppFeature.State(),
        reducer: {
            AppFeature()
                ._printChanges()
        }
    )

    var body: some Scene {
        WindowGroup {
            FoodList(
                store: store.scope(
                    state: \.foodList,
                    action: \.foodList
                )
            )
        }
    }
}
