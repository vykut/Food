import SwiftUI
import ComposableArchitecture
import TabBar

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
            TabBar(
                store: store.scope(state: \.tabBar, action: \.tabBar)
            )
        }
    }
}
