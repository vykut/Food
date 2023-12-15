import SwiftUI
import ComposableArchitecture
import Shared
import FoodComparison

public struct FoodSelection: View {
    @Bindable var store: StoreOf<FoodSelectionFeature>

    public init(store: StoreOf<FoodSelectionFeature>) {
        self.store = store
    }

    public var body: some View {
        List(selection: $store.selectedFoodIds.sending(\.updateSelection)) {
            recentSearchesSection
        }
        .listStyle(.sidebar)
        .searchable(
            text: $store.filterQuery.sending(\.updateFilter),
            prompt: "Filter"
        )
        .environment(\.editMode, .constant(.active))
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbar
        }
        .navigationDestination(
            item: $store.scope(state: \.foodComparison, action: \.foodComparison),
            destination: { store in
                FoodComparison(store: store)
            }
        )
        .onFirstAppear {
            store.send(.onFirstAppear)
        }
    }

    private var recentSearchesSection: some View {
        Section {
            ForEach(store.filteredFoods, id: \.id) { item in
                Text(item.name.capitalized)
                    .selectionDisabled(store.state.isSelectionDisabled(for: item))
            }
        } header: {
            Text("Recent searches")
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if store.shouldShowCancelButton {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu("Compare") {
                ForEach(Comparison.allCases) { comparison in
                    Button(comparison.rawValue.capitalized) {
                        store.send(.compareButtonTapped(comparison))
                    }
                }
            }
            .disabled(store.isCompareButtonDisabled)
        }
    }

    private var navigationTitle: String {
        if store.selectedFoodIds.count < 2 {
            "Select \(2 - store.selectedFoodIds.count) or more"
        } else {
            "\(store.selectedFoodIds.count) foods selected"
        }
    }
}

#Preview {
    NavigationStack {
        FoodSelection(
            store: .init(
                initialState: FoodSelectionFeature.State(),
                reducer: {
                    FoodSelectionFeature()
                        ._printChanges()
                }
            )
        )
    }
}

fileprivate extension Food {
    init(id: Int64, name: String) {
        self.init(
            id: id,
            name: name,
            energy: .zero,
            fatTotal: .zero,
            fatSaturated: .zero,
            protein: .zero,
            sodium: .zero,
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .zero,
            fiber: .zero,
            sugar: .zero
        )
    }
}
