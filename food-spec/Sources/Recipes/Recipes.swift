import SwiftUI
import Shared
import ComposableArchitecture

public struct Recipes: View {
    @Bindable var store: StoreOf<RecipesFeature>

    public init(store: StoreOf<RecipesFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Recipes")
    }
}

#Preview {
    Recipes(
        store: .init(
            initialState: RecipesFeature.State(),
            reducer: {
                RecipesFeature()
            }
        )
    )
}
