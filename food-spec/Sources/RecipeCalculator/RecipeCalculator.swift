import SwiftUI
import Shared
import ComposableArchitecture

public struct SwiftUIView: View {
    @Bindable var store: StoreOf<RecipeCalculatorFeature>

    public init(store: StoreOf<RecipeCalculatorFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    SwiftUIView(
        store: .init(
            initialState: RecipeCalculatorFeature.State(),
            reducer: {
                RecipeCalculatorFeature()
            }
        )
    )
}
