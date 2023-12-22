import SwiftUI
import FoodObservation
import ComposableArchitecture

struct SearchableFoodModifier: ViewModifier {
    @Bindable var store: StoreOf<FoodSearch>
    var prompt: String

    func body(content: Content) -> some View {
        content
            .searchable(
                text: self.$store.query.sending(\.updateQuery).animation(),
                isPresented: self.$store.isFocused.sending(\.updateFocus).animation(),
                prompt: prompt
            )
            .submitLabel(.search)
            .onSubmit(of: .search) {
                self.store.send(.searchSubmitted, animation: .default)
            }
            .foodObservation(
                store: self.store.scope(state: \.foodObservation, action: \.foodObservation)
            )
    }
}

public extension View {
    func searchableFood(store: StoreOf<FoodSearch>, prompt: String = "Search") -> some View {
        self
            .modifier(SearchableFoodModifier(store: store, prompt: prompt))
    }
}
