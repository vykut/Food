import SwiftUI
import Shared
import ComposableArchitecture

public struct RecipeList: View {
    @Bindable var store: StoreOf<RecipeListFeature>

    public init(store: StoreOf<RecipeListFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            if !store.recipes.isEmpty {
                recipesSection
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
        .navigationTitle("Recipes")
        .task {
            await store.send(.onTask).finish()
        }
    }

    private var recipesSection: some View {
        Section("Recipes") {
            ForEach(store.recipes, id: \.id) { recipe in
                VStack(alignment: .leading) {
                    let nutritionalValues = recipe.nutritionalValues
                    Text(recipe.name.capitalized)
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
    RecipeList(
        store: .init(
            initialState: RecipeListFeature.State(),
            reducer: {
                RecipeListFeature()
            }
        )
    )
}
