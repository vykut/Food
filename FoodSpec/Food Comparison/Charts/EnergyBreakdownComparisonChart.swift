//
//  EnergyBreakdownComparisonChart.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 10/12/2023.
//

import SwiftUI
import Charts

struct EnergyBreakdownComparisonChart: View {
    let foods: [Food]
    let calculator = EnergyCalculator()

    var body: some View {
        Chart(foods, id: \.id, content: chartContent)
            .chartXAxis { xAxis }
            .chartYAxis { yAxis }
            .chartXScale(domain: [Energy.zero, maxXScale])
            .chartForegroundStyleScale(
                range: [Color.red, .yellow, .brown]
            )
            .chartLegend(spacing: 32)
    }

    @ChartContentBuilder
    private func chartContent(food: Food) -> some ChartContent {
        let energy = calculator.calculateEnergy(for: food)
        ForEach(
            [
                (name: "Protein", energy: energy.protein),
                (name: "Carbohydrate", energy: energy.carbohydrates),
                (name: "Fat", energy: energy.fat)
            ],
            id: \.name
        ) { breakdown in
            BarMark(
                x: .value(breakdown.name.capitalized, breakdown.energy),
                y: .value("Name", summary(for: food, breakdown: energy))
            )
            .foregroundStyle(by: .value("Type", breakdown.name.capitalized))
            .alignsMarkStylesWithPlotArea()
        }
    }

    private var xAxis: some AxisContent {
        AxisMarks(preset: .inset) {
            AxisGridLine()
            AxisValueLabel(
                format: EnergyFormat.measurement(width: .abbreviated, usage: .asProvided),
                anchor: .top
            )
        }
    }

    private var yAxis: some AxisContent {
        AxisMarks(preset: .inset) {
            AxisValueLabel()
        }
    }

    private var maxXScale: Energy {
        max(
            foods.max(by: { $0.energy < $1.energy })!.energy,
            foods.map(calculator.calculateEnergy).max(by: { $0.total < $1.total })!.total
        )
    }

    private func summary(for food: Food, breakdown: EnergyCalculator.EnergyBreakdown) -> String {
"""
\(food.name.capitalized)
\(food.energy.formatted(width: .abbreviated)) | \
Protein: \(breakdown.proteinRatio.formatted(.percent.precision(.fractionLength(0...1)))) | \
Carbohydrates: \(breakdown.carbohydratesRatio.formatted(.percent.precision(.fractionLength(0...1)))) | \
Fat: \(breakdown.fatRatio.formatted(.percent.precision(.fractionLength(0...1))))
"""
    }
}

#Preview {
    EnergyBreakdownComparisonChart(
        foods: [
            .init(id: 1, name: "banana", energy: 89.4, protein: 1.1, carbs: 23.2, fat: 0.3),
            .init(id: 2, name: "blueberry", energy: 56.2, protein: 0.7, carbs: 14.8, fat: 0),
            .init(id: 3, name: "cantaloupe", energy: 33.8, protein: 0.8, carbs: 8.1, fat: 0.2),
            .init(id: 4, name: "lettuce", energy: 17, protein: 1.2, carbs: 3.3, fat: 0.3),
            .init(id: 5, name: "melon", energy: 33.6, protein: 0.8, carbs: 8.3, fat: 0.2),
            .init(id: 6, name: "strawberry", energy: 31.9, protein: 0.7, carbs: 7.7, fat: 0.3),
            .init(id: 7, name: "watermelon", energy: 30.3, protein: 0.6, carbs: 7.4, fat: 0.1),
        ]
    )
    .padding()
}

extension Energy: Plottable {
    var primitivePlottable: Double {
        value
    }

    init?(primitivePlottable: Double) {
        self.init(kcal: primitivePlottable)
    }
}

fileprivate extension Food {
    init(id: Int64, name: String, energy: Double, protein: Double, carbs: Double, fat: Double) {
        self.init(
            id: id,
            name: name,
            energy: .init(kcal: energy),
            fatTotal: .init(grams: fat),
            fatSaturated: .zero,
            protein: .init(grams: protein),
            sodium: .zero,
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .init(grams: carbs),
            fiber: .zero,
            sugar: .zero
        )
    }
}
