import SwiftUI
import ComposableArchitecture
import Shared
import FoodComparison

public struct FoodSelectionScreen: View {
    @Bindable var store: StoreOf<FoodSelection>

    public init(store: StoreOf<FoodSelection>) {
        self.store = store
    }

    public var body: some View {
        List(selection: $store.selectedFoodIds.sending(\.updateSelection)) {
            if !self.store.filteredFoods.isEmpty {
                recentSearchesSection
            }
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
                FoodComparisonScreen(store: store)
            }
        )
        .onFirstAppear {
            store.send(.onFirstAppear)
        }
    }

    private var recentSearchesSection: some View {
        Section {
            ForEach(store.filteredFoods, id: \.id) { item in
                LabeledListRow(title: item.name.capitalized)
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
        FoodSelectionScreen(
            store: .init(
                initialState: FoodSelection.State(),
                reducer: {
                    FoodSelection()
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
