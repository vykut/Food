import SwiftUI
import ComposableArchitecture

struct FoodSearchModifier: ViewModifier {
    @Bindable var store: StoreOf<FoodSearch>
    var prompt: String

    func body(content: Content) -> some View {
        content
            .searchable(
                text: self.$store.query.sending(\.updateQuery).animation(),
                isPresented: self.$store.isFocused.sending(\.updateFocus).animation(),
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: prompt
            )
            .submitLabel(.search)
            .onSubmit(of: .search) {
                self.store.send(.searchSubmitted, animation: .default)
            }
            .alert(self.$store.scope(state: \.alert, action: \.alert))
    }
}

public extension View {
    func foodSearch(store: StoreOf<FoodSearch>, prompt: String = "Search") -> some View {
        self
            .modifier(FoodSearchModifier(store: store, prompt: prompt))
    }
}
