import SwiftUI
import Shared
import ComposableArchitecture

public struct MealList: View {
    @Bindable var store: StoreOf<MealListFeature>

    public init(store: StoreOf<MealListFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            if !store.meals.isEmpty {
                mealsSection
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.plusButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("Meals")
        .task {
            await store.send(.onTask).finish()
        }
    }

    private var mealsSection: some View {
        Section {
            ForEach(store.meals, id: \.id) { meal in
                VStack(alignment: .leading) {
                    let nutritionalValues = meal.nutritionalValues
                    Text(meal.name.capitalized)
                    Text(nutritionalValues.food.nutritionalSummary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete { offsets in
                self.store.send(.onDelete(offsets))
            }
        }
    }
}

#Preview {
    MealList(
        store: .init(
            initialState: MealListFeature.State(),
            reducer: {
                MealListFeature()
            }
        )
    )
}
