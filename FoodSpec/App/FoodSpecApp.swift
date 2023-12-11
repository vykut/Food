import SwiftUI
import ComposableArchitecture
import FoodList

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
