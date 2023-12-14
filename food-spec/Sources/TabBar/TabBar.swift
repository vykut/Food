import SwiftUI
import FoodList
import FoodSelection
import MealList
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
                mealList
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
    private var mealList: some View {
        NavigationStack {
            MealList(
                store: store.scope(state: \.mealList, action: \.mealList)
            )
        }
        .tint(Color.blue)
        .tabItem {
            Label("Meals", systemImage: "fork.knife")
        }
        .tag(Tab.mealList)
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
