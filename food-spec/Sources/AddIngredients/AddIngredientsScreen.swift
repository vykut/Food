import SwiftUI
import Shared
import IngredientPicker
import Database
import ComposableArchitecture

public struct AddIngredientsScreen: View {
    @Bindable var store: StoreOf<AddIngredients>
    @FocusState private var focusedField: String?

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
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    self.store.send(.doneButtonTapped)
                }
            }
            DefaultKeyboardToolbar()
        }
        .environment(\.focusState, $focusedField)
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

public struct DefaultKeyboardToolbar: ToolbarContent {
    @Environment(\.focusState) var focusState

    public init() { }

    public var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                focusState.wrappedValue = nil
            }
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