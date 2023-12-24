import SwiftUI
import ComposableArchitecture

struct FoodObservationModifier: ViewModifier {
    let store: StoreOf<FoodObservation>

    init(store: StoreOf<FoodObservation>) {
        self.store = store
    }

    func body(content: Content) -> some View {
        content
            .onFirstAppear {
                self.store.send(.startObservation, animation: .default)
            }
    }
}

public extension View {
    func foodObservation(store: StoreOf<FoodObservation>) -> some View {
        self
            .modifier(FoodObservationModifier(store: store))
    }
}

#Preview {
    Text("Food Observation")
        .foodObservation(
            store: .init(
                initialState: FoodObservation.State(),
                reducer: {
                    FoodObservation()
                }
            )
        )
}
