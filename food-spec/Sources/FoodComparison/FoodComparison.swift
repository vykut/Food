import SwiftUI
import Shared
import ComposableArchitecture

public struct FoodComparison: View {
    typealias SortingStrategy = FoodComparisonFeature.State.SortingStrategy

    @Bindable var store: StoreOf<FoodComparisonFeature>

    public init(store: StoreOf<FoodComparisonFeature>) {
        self.store = store
    }

    public var body: some View {
        Section {
            chart
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
        .toolbarTitleMenu {
            comparisonMenu
        }
    }

    @ViewBuilder
    private var chart: some View {
        switch store.comparison {
            case .energy:
                EnergyBreakdownComparisonChart(
                    foods: store.comparedFoods
                )
            case .protein:
                QuantityComparisonChart(
                    foods: store.comparedFoods,
                    keyPath: \.protein,
                    name: "Protein",
                    color: .red
                )
            case .carbohydrate:
                QuantityComparisonChart(
                    foods: store.comparedFoods,
                    keyPath: \.carbohydrate,
                    name: "Carbohydrate",
                    color: .yellow
                )
            case .sugar:
                QuantityComparisonChart(
                    foods: store.comparedFoods,
                    keyPath: \.sugar,
                    name: "Sugar",
                    color: .teal
                )
            case .fiber:
                QuantityComparisonChart(
                    foods: store.comparedFoods,
                    keyPath: \.fiber,
                    name: "Fiber",
                    color: .green
                )
            case .fat:
                QuantityComparisonChart(
                    foods: store.comparedFoods,
                    keyPath: \.fatTotal,
                    name: "Fat",
                    color: .brown
                )
            case .saturatedFat:
                QuantityComparisonChart(
                    foods: store.comparedFoods,
                    keyPath: \.fatSaturated,
                    name: "Saturated Fat",
                    color: .gray
                )
            case .cholesterol:
                QuantityComparisonChart(
                    foods: store.comparedFoods,
                    keyPath: \.cholesterol.convertedToMilligrams,
                    name: "Cholesterol",
                    color: .orange
                )
            case .potassium:
                QuantityComparisonChart(
                    foods: store.comparedFoods,
                    keyPath: \.potassium.convertedToMilligrams,
                    name: "Potassium",
                    color: .purple
                )
            case .sodium:
                QuantityComparisonChart(
                    foods: store.comparedFoods,
                    keyPath: \.sodium.convertedToMilligrams,
                    name: "Sodium",
                    color: .mint
                )
            case .macronutrients:
                MacronutrientsComparisonChart(
                    foods: store.comparedFoods
                )
        }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            sortMenu
        }
    }

    private var comparisonMenu: some View {
        Picker(
            "Comparison Type",
            selection: self.$store.comparison.sending(\.updateComparisonType)
        ) {
            ForEach(Comparison.allCases) { comparison in
                Text(comparison.rawValue.capitalized)
                    .tag(comparison)
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker(
                "Sort by",
                selection: self.$store.foodSortingStrategy.sending(\.updateSortingStrategy)
            ) {
                ForEach(self.store.availableSortingStrategies) { strategy in
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
            initialState: FoodComparisonFeature.State(),
            reducer: {
                FoodComparisonFeature()
            }
        )
    )
}

fileprivate extension Quantity {
    var convertedToMilligrams: Self {
        converted(to: .milligrams)
    }
}
