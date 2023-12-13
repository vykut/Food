import Foundation
import ComposableArchitecture
import Shared
import QuantityPicker

@Reducer
public struct FoodComparisonFeature {
    @ObservableState
    public struct State: Hashable {
        var originalFoods: [Food]
        var comparison: Comparison
        var foodSortingStrategy: SortingStrategy = .value
        var foodSortingOrder: SortOrder = .forward
        var quantityPicker: QuantityPickerFeature.State = .init()

        var availableSortingStrategies: [SortingStrategy] {
            if [Comparison.energy, .macronutrients].contains(comparison) {
                SortingStrategy.allCases
            } else {
                [.name, .value]
            }
        }

        var comparedFoods: [Food] {
            originalFoods
                .map {
                    $0.changingServingSize(to: quantityPicker.quantity)
                }
                .sorted(
                    by: foodSortingStrategy,
                    comparison: comparison,
                    order: foodSortingOrder
                )
        }

        public enum SortingStrategy: String, Identifiable, Hashable, CaseIterable {
            case name
            case value
            case protein
            case carbohydrate
            case fat

            public var id: Self { self }
        }

        public init(
            foods: [Food],
            comparison: Comparison,
            foodSortingStrategy: SortingStrategy = .value,
            foodSortingOrder: SortOrder = .forward
        ) {
            self.originalFoods = foods
            self.comparison = comparison
            self.foodSortingStrategy = foodSortingStrategy
            self.foodSortingOrder = foodSortingOrder
        }
    }

    @CasePathable
    public enum Action {
        case updateSortingStrategy(State.SortingStrategy)
        case updateComparisonType(Comparison)
        case quantityPicker(QuantityPickerFeature.Action)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.quantityPicker, action: \.quantityPicker) {
            QuantityPickerFeature()
        }
        Reduce { state, action in
            switch action {
                case .updateSortingStrategy(let strategy):
                    if state.foodSortingStrategy == strategy {
                        state.foodSortingOrder.toggle()
                    } else {
                        state.foodSortingStrategy = strategy
                        state.foodSortingOrder = .forward
                    }
                    return .none

                case .updateComparisonType(let comparison):
                    guard comparison != state.comparison else { return .none }
                    state.comparison = comparison
                    let isSortingByInvalidCriteria = ![.energy, .macronutrients].contains(comparison) && [.protein, .carbohydrate, .fat].contains(state.foodSortingStrategy)
                    if isSortingByInvalidCriteria {
                        state.foodSortingStrategy = .value
                        state.foodSortingOrder = .forward
                    }
                    return .none

                case .quantityPicker(let action):
                    return reduce(state: &state, action: action)
            }
        }
    }

    private func reduce(state: inout State, action: QuantityPickerFeature.Action) -> Effect<Action> {
        // nothing
        return .none
    }
}

extension Array<Food> {
    mutating func sort(
        by strategy: FoodComparisonFeature.State.SortingStrategy,
        comparison: Comparison?,
        order: SortOrder
    ) {
        switch strategy {
            case .name:
                sort(using: SortDescriptor(\.name, order: order))
            case .value:
                if let comparison {
                    sort(by: comparison, order: order)
                }
            case .protein:
                sort(using: SortDescriptor(\.protein, order: order))
            case .carbohydrate:
                sort(using: SortDescriptor(\.carbohydrate, order: order))
            case .fat:
                sort(using: SortDescriptor(\.fatTotal, order: order))
        }
    }

    func sorted(
        by strategy: FoodComparisonFeature.State.SortingStrategy,
        comparison: Comparison,
        order: SortOrder
    ) -> [Food] {
        var copy = self
        copy.sort(by: strategy, comparison: comparison, order: order)
        return copy
    }
}

extension Array<Food> {
    mutating func sort(by comparison: Comparison, order: SortOrder) {
        switch comparison {
            case .energy:
                let descriptor = SortDescriptor(\Food.energy, order: order)
                self.sort(using: descriptor)
            case .protein, .carbohydrate, .fat, .cholesterol, .potassium, .sodium, .macronutrients, .sugar, .fiber, .saturatedFat:
                let keyPath: KeyPath<Food, Quantity> = switch comparison {
                case .protein: \.protein
                case .carbohydrate: \.carbohydrate
                case .sugar: \.sugar
                case .fiber: \.fiber
                case .saturatedFat: \.fatSaturated
                case .fat: \.fatTotal
                case .cholesterol: \.cholesterol
                case .potassium: \.potassium
                case .sodium: \.sodium
                case .macronutrients: \.macronutrients
                case .energy: fatalError()
                }
                let descriptor = SortDescriptor(keyPath, order: order)
                self.sort(using: descriptor)
        }
    }

    func sorted(by comparison: Comparison, order: SortOrder) -> [Food] {
        var copy = self
        copy.sort(by: comparison, order: order)
        return copy
    }
}

extension Food {
    var macronutrients: Quantity {
        protein + carbohydrate + fatTotal
    }
}
