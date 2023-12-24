import SwiftUI
import Shared
import ComposableArchitecture

struct MealObservationModifier: ViewModifier {
    let store: StoreOf<MealObservation>

    init(store: StoreOf<MealObservation>) {
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
    func mealObservation(store: StoreOf<MealObservation>) -> some View {
        self
            .modifier(MealObservationModifier(store: store))
    }
}

#Preview {
    Text("Meal Observation")
        .mealObservation(
            store: .init(
                initialState: MealObservation.State(),
                reducer: {
                    MealObservation()
                }
            )
        )
}

