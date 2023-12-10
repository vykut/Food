//
//  EnergyBreakdownChart.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 08/12/2023.
//

import SwiftUI
import Charts

struct EnergyBreakdownChart: View {
    let food: Food
    let calculator = EnergyCalculator()

    var body: some View {
        let breakdown = calculator.calculateEnergy(for: food)
        let categories = [
            (name: "Protein", energy: breakdown.protein, ratio: breakdown.proteinRatio, color: Color.red),
            (name: "Carbohydrate", energy: breakdown.carbohydrate, ratio: breakdown.carbohydrateRatio, color: .yellow),
            (name: "Fat", energy: breakdown.fat, ratio: breakdown.fatRatio, color: .brown),
        ]
        Chart {
            ForEach(categories, id: \.name) { category in
                SectorMark(
                    angle: .value("Type", category.energy.value),
                    angularInset: 1
                )
                .foregroundStyle(
                    by: .value("Type", "\(category.name) \(category.ratio.formatted(.percent.precision(.fractionLength(1))))")
                )
                .alignsMarkStylesWithPlotArea()
            }
        }
        .chartForegroundStyleScale(
            range: [.red, .yellow, .brown]
        )
        .chartLegend(
            position: .trailing,
            alignment: .trailing,
            spacing: 16
        )
    }
}

extension CGRect {
    var center: CGPoint { .init(x: midX, y: midY)}
}

#Preview {
    EnergyBreakdownChart(
        food: .init(
            name: "Mock",
            energy: .init(value: 108, unit: .kilocalories),
            fatTotal: .init(value: 4, unit: .grams),
            fatSaturated: .init(value: 4, unit: .grams),
            protein: .init(value: 9, unit: .grams),
            sodium: .init(value: 4, unit: .grams),
            potassium: .init(value: 4, unit: .grams),
            cholesterol: .init(value: 4, unit: .grams),
            carbohydrate: .init(value: 9, unit: .grams),
            fiber: .init(value: 4, unit: .grams),
            sugar: .init(value: 4, unit: .grams)
        )
    )
    .padding()
}
