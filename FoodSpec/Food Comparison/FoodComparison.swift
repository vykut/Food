//
//  FoodComparison.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 09/12/2023.
//

import SwiftUI
import ComposableArchitecture

struct FoodComparison: View {
    @Bindable var store: StoreOf<FoodComparisonReducer>
    typealias SortingStrategy = FoodComparisonReducer.State.SortingStrategy
    typealias Comparison = FoodComparisonReducer.State.Comparison

    var body: some View {
        Section {
            ComparisonChart(
                foods: store.comparedFoods
            )
        } header: {
            Text(
                "Nutritional values per \(Quantity(value: 100, unit: .grams).formatted(width: .wide))"
            )
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding([.horizontal, .bottom])
        .toolbar {
            toolbar
        }
        .navigationTitle("\(store.comparison.rawValue.capitalized) comparison")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            comparisonMenu
        }
        ToolbarItem(placement: .topBarTrailing) {
            sortMenu
        }
    }

    private var comparisonMenu: some View {
        Menu {
            Picker(
                "Comparison Type",
                selection: self.$store.comparison.sending(\.updateComparisonType)
            ) {
                ForEach(Comparison.allCases) { comparison in
                    Text(comparison.rawValue.capitalized)
                        .tag(comparison)
                }
            }
        } label: {
            Image(systemName: "list.bullet")
                .imageScale(.medium)
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker(
                "Sort by",
                selection: self.$store.foodSortingStrategy.sending(\.updateSortingStrategy)
            ) {
                ForEach([SortingStrategy.name, .value]) { strategy in
                    let text = strategy.rawValue.capitalized
                    ZStack {
                        if strategy == self.store.foodSortingStrategy {
                            let systemImageName = self.store.foodSortingOrder == .forward ? "chevron.up" : "chevron.down"
                            Label(text, systemImage: systemImageName)
                                .imageScale(.small)
                        } else {
                            Text(text)
                        }
                    }
                    .tag(strategy)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .imageScale(.medium)
        }
        .menuActionDismissBehavior(.disabled)
    }
}

#Preview {
    FoodComparison(
        store: Store(
            initialState: FoodComparisonReducer.State(),
            reducer: {
                FoodComparisonReducer()
            }
        )
    )
}
