//
//  FoodSelection.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 09/12/2023.
//

import SwiftUI
import ComposableArchitecture

struct FoodSelection: View {
    @Bindable var store: StoreOf<FoodComparisonFeature>

    var body: some View {
        List(selection: $store.selectedFoodIds.sending(\.didChangeSelection)) {
            recentSearchesSection
        }
        .listStyle(.sidebar)
        .searchable(
            text: $store.filterQuery.sending(\.updateFilterQuery),
            prompt: "Filter"
        )
        .environment(\.editMode, .constant(.active))
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbar
        }
        .navigationDestination(
            isPresented: $store.isShowingComparison.sending(\.didNavigateToComparison),
            destination: {
                FoodComparison(store: store)
            }
        )
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
        ToolbarItem(placement: .topBarLeading) {
            Button {
                store.send(.didTapCancel)
            } label: {
                Image(systemName: "xmark")
                    .imageScale(.medium)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu("Compare") {
                ForEach(Comparison.allCases) { comparison in
                    Button(comparison.rawValue.capitalized) {
                        store.send(.didTapCompare(comparison))
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
                initialState: FoodComparisonFeature.State(
                    foods: [
                        .init(id: 1, name: "eggplant"),
                        .init(id: 2, name: "ribeye"),
                        .init(id: 3, name: "strawberry"),
                    ],
                    selectedFoodIds: [1]
                ),
                reducer: {
                    FoodComparisonFeature()
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
