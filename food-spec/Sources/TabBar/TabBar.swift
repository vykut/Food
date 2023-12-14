import SwiftUI
import FoodList
import FoodSelection
import RecipeList
import ComposableArchitecture

public struct TabBar: View {
    typealias Tab = TabBarFeature.State.Tab

    @Bindable var store: StoreOf<TabBarFeature>

    public init(store: StoreOf<TabBarFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(
            selection: $store.tab.sending(\.updateTab),
            content: {
                foodList
                foodSelection
                recipes
            }
        )
        .tint(.primary)
    }

    @MainActor
    private var foodList: some View {
        NavigationStack {
            FoodList(
                store: store.scope(state: \.foodList, action: \.foodList)
            )
        }
        .tint(Color.blue)
        .tabItem {
            Label("Search", systemImage: "magnifyingglass")
        }
        .tag(Tab.foodList)
    }

    @MainActor
    private var foodSelection: some View {
        NavigationStack {
            FoodSelection(
                store: store.scope(state: \.foodSelection, action: \.foodSelection)
            )
        }
        .tint(Color.blue)
        .tabItem {
            Label("Food Comparison", systemImage: "shuffle")
        }
        .tag(Tab.foodSelection)
    }

    @MainActor
    private var recipes: some View {
        NavigationStack {
            RecipeList(
                store: store.scope(state: \.recipeList, action: \.recipeList)
            )
        }
        .tint(Color.blue)
        .tabItem {
            Label("Recipes", systemImage: "fork.knife")
        }
        .tag(Tab.recipeList)
    }
}

#Preview {
    TabBar(
        store: .init(
            initialState: TabBarFeature.State(),
            reducer: {
                TabBarFeature()
            }
        )
    )
}
