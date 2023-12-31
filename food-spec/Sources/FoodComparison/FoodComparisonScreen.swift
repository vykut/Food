import SwiftUI
import Shared
import ComposableArchitecture
import QuantityPicker

public struct FoodComparisonScreen: View {
    typealias SortingStrategy = FoodComparison.State.SortingStrategy

    @Bindable var store: StoreOf<FoodComparison>

    public init(store: StoreOf<FoodComparison>) {
        self.store = store
    }

    public var body: some View {
        Section {
            chart
        } header: {
            if let store = self.store.scope(state: \.quantityPicker, action: \.quantityPicker) {
                QuantityPickerView(
                    store: store
                )
                .quantityPickerStyle(.dropdown)
            }
        }
        .padding([.horizontal, .bottom])
        .toolbar {
            toolbar
        }
        .navigationTitle(store.comparison.rawValue.capitalized)
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
    FoodComparisonScreen(
        store: Store(
            initialState: FoodComparison.State(
                foods: (1...7).map { Food.preview(id: $0, name: "eggplant\($0)") },
                comparison: .energy
            ),
            reducer: {
                FoodComparison()
            }
        )
    )
}

fileprivate extension Quantity {
    var convertedToMilligrams: Self {
        converted(to: .milligrams)
    }
}
