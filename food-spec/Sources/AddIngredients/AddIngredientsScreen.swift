import SwiftUI
import Shared
import IngredientPicker
import Database
import ComposableArchitecture

public struct AddIngredientsScreen: View {
    @Bindable var store: StoreOf<AddIngredients>

    public init(store: StoreOf<AddIngredients>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEachStore(self.store.scope(
                    state: \.ingredientPickers,
                    action: \.ingredientPickers)
                ) { store in
                    IngredientPickerView(store: store)
                        .padding(.horizontal)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    self.store.send(.doneButtonTapped)
                }
            }
        }
        .navigationTitle(navigationTitle)
        .onFirstAppear {
            self.store.send(.onFirstAppear)
        }
    }

    private var navigationTitle: LocalizedStringKey {
        if self.store.selectedIngredients.isEmpty {
            "Select ingredients"
        } else {
            "^[\(self.store.selectedIngredients.count) ingredient](inflect: true) selected"
        }
    }
}

#Preview {
    NavigationStack {
        AddIngredientsScreen(
            store: .init(
                initialState: AddIngredients.State(
                    ingredients: [
                        .init(foodId: 2),
                        .init(foodId: 3),
                    ]
                ),
                reducer: {
                    AddIngredients()
                        .dependency(\.databaseClient.getRecentFoods, { _, _ in
                            [
                                .preview(id: 1),
                                .preview(id: 2),
                                .preview(id: 3),
                                .preview(id: 4),
                                .preview(id: 5),
                            ]
                        })
                }
            )
        )
    }
}

fileprivate extension Ingredient {
    init(foodId: Int64) {
        self.init(
            food: .preview(id: foodId),
            quantity: .init(value: 1.5, unit: .pounds)
        )
    }
}
