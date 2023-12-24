import SwiftUI
import Shared
import Spotlight
import ComposableArchitecture

struct SpotlightModifier: ViewModifier {
    let store: StoreOf<SpotlightReducer>

    func body(content: Content) -> some View {
        content
            .onFirstAppear {
                store.send(.start)
            }
            .onContinueUserActivity(CSSearchableItemActionType) { activity in
                self.store.send(.handleSelectedItem(activity))
            }
            .onContinueUserActivity(CSQueryContinuationActionType) { activity in
                self.store.send(.handleSearchInApp(activity))
            }
    }
}

public extension View {
    func spotlightModifier(store: StoreOf<SpotlightReducer>) -> some View {
        self
            .modifier(SpotlightModifier(store: store))
    }
}

#Preview {
    Text("Spotlight")
        .spotlightModifier(
            store: .init(
                initialState: SpotlightReducer.State(),
                reducer: {
                    SpotlightReducer()
                }
            )
        )
}
