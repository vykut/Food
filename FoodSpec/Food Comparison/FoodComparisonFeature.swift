//
//  FoodComparisonFeature.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 09/12/2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FoodComparisonFeature {
    @ObservableState
    struct State: Hashable {
        var foods: [Food] = []
        var selectedFoodIds: Set<Int64?> = []
        var comparedFoods: [Food] = []
        var filterQuery: String = ""
        var isShowingComparison: Bool = false
        var comparison: Comparison = .energy
        var foodSortingStrategy: SortingStrategy = .value
        var foodSortingOrder: SortOrder = .forward

        var filteredFoods: [Food] {
            guard !filterQuery.isEmpty else { return foods }
            return foods.filter {
                $0.name.range(of: filterQuery, options: .caseInsensitive) != nil
            }
        }

        var isCompareButtonDisabled: Bool {
            selectedFoodIds.count < 2
        }

        func isSelectionDisabled(for food: Food) -> Bool {
            selectedFoodIds.count >= 7 &&
            !selectedFoodIds.contains(food.id)
        }

        var availableSortingStrategies: [SortingStrategy] {
            if [Comparison.energy, .macronutrients].contains(comparison) {
                SortingStrategy.allCases
            } else {
                [.name, .value]
            }
        }

        enum SortingStrategy: String, Identifiable, Hashable, CaseIterable {
            case name
            case value
            case protein
            case carbohydrate
            case fat

            var id: Self { self }
        }
    }

    @CasePathable
    enum Action {
        case didTapCancel
        case didTapCompare(Comparison)
        case didChangeSelection(Set<Int64?>)
        case didNavigateToComparison(Bool)
        case updateFilterQuery(String)
        case updateSortingStrategy(State.SortingStrategy)
        case updateComparisonType(Comparison)
    }

    @Dependency(\.dismiss) private var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .didChangeSelection(let selection):
                    state.selectedFoodIds = selection
                    return .none

                case .didTapCompare(let comparison):
                    state.comparison = comparison
                    state.comparedFoods = state.filteredFoods
                        .filter { [selectedIds = state.selectedFoodIds] food in
                            selectedIds.contains(food.id)
                        }
                    sortFoods(state: &state)
                    state.isShowingComparison = true

                    return .none

                case .updateFilterQuery(let query):
                    state.filterQuery = query
                    return .none

                case .updateSortingStrategy(let strategy):
                    if state.foodSortingStrategy == strategy {
                        state.foodSortingOrder.toggle()
                    } else {
                        state.foodSortingStrategy = strategy
                        state.foodSortingOrder = .forward
                    }
                    sortFoods(state: &state)
                    return .none

                case .updateComparisonType(let comparison):
                    state.comparison = comparison
                    let isSortingByInvalidCriteria = ![.energy, .macronutrients].contains(comparison) && [.protein, .carbohydrate, .fat].contains(state.foodSortingStrategy)
                    if isSortingByInvalidCriteria {
                        state.foodSortingStrategy = .value
                        state.foodSortingOrder = .forward
                    }
                    sortFoods(state: &state)
                    return .none

                case .didTapCancel:
                    return .run { _ in
                        await dismiss()
                    }

                case .didNavigateToComparison(let bool):
                    guard bool != state.isShowingComparison else { return .none }
                    state.isShowingComparison = bool
                    return .none
            }
        }
    }

    private func sortFoods(state: inout State) {
        state.comparedFoods.sort(
            by: state.foodSortingStrategy,
            comparison: state.comparison,
            order: state.foodSortingOrder
        )
    }
}

extension Array<Food> {
    mutating func sort(
        by strategy: FoodComparisonFeature.State.SortingStrategy,
        comparison: Comparison,
        order: SortOrder
    ) {
        switch strategy {
            case .name:
                sort(using: SortDescriptor(\.name, order: order))
            case .value:
                sort(by: comparison, order: order)
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
