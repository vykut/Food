import SwiftUI
import FoodList
import FoodSelection
import MealList
import ComposableArchitecture

public struct TabBarScreen: View {
    typealias Tab = TabBar.State.Tab

    @Bindable var store: StoreOf<TabBar>

    public init(store: StoreOf<TabBar>) {
        self.store = store
    }

    public var body: some View {
        TabView(
            selection: $store.tab.sending(\.updateTab),
            content: {
                foodList
                mealList
                foodSelection
            }
        )
    }

    @MainActor
    private var foodList: some View {
        NavigationStack {
            FoodListScreen(
                store: store.scope(state: \.foodList, action: \.foodList)
            )
        }
        .tabItem {
            Label("Search", systemImage: "magnifyingglass")
        }
        .tag(Tab.foodList)
    }

    @MainActor
    private var foodSelection: some View {
        NavigationStack {
            FoodSelectionScreen(
                store: store.scope(state: \.foodSelection, action: \.foodSelection)
            )
        }
        .tabItem {
            Label("Compare", systemImage: "shuffle")
        }
        .tag(Tab.foodSelection)
    }

    @MainActor
    private var mealList: some View {
        NavigationStack {
            MealListScreen(
                store: store.scope(state: \.mealList, action: \.mealList)
            )
        }
        .tabItem {
            Label("Meals", systemImage: "fork.knife")
        }
        .tag(Tab.mealList)
    }
}

#Preview {
    TabBarScreen(
        store: .init(
            initialState: TabBar.State(),
            reducer: {
                TabBar()
            }
        )
    )
}
