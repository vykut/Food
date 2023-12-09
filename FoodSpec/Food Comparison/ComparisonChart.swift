//
//  ComparisonChart.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 10/12/2023.
//

import SwiftUI
import Charts

struct ComparisonChart: View {
    let foods: [Food]

    var body: some View {
        Chart {
            ForEach(foods, id: \.id) { food in
                BarMark(
                    x: .value("Energy", food.energy),
                    y: .value("Name", "\(food.name.capitalized)\n\(food.energy.formatted(width: .abbreviated))")
                )
                .foregroundStyle(by: .value("Type", "Energy"))
//                .annotation(position: .trailing, alignment: .trailing, spacing: 8) {
//                    Text(food.energy.formatted(width: .abbreviated))
//                        .font(.footnote)
//                        .foregroundStyle(.secondary)
//                }
                .alignsMarkStylesWithPlotArea()
            }
        }
        .chartXAxis {
            AxisMarks(preset: .inset) {
                AxisGridLine()
                AxisValueLabel(
                    format: .measurement(width: .abbreviated, usage: .asProvided),
                    anchor: .top
                )
            }
        }
        .chartYAxis {
            AxisMarks(preset: .inset) {
                AxisValueLabel()
            }
        }
        .chartXScale(
            domain: [
                Energy.zero,
                foods.max(by: { $0.energy < $1.energy })!.energy
            ]
        )
        .chartForegroundStyleScale(
            range: [
                LinearGradient(
                    colors: [.green, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            ],
            type: .category
        )
        .chartLegend(spacing: 16)
    }
}

#Preview {
    ComparisonChart(
        foods: [
            .init(id: 1, name: "lettuce", energy: 17),
            .init(id: 2, name: "asparagus", energy: 21.4),
            .init(id: 2, name: "mushroom", energy: 28),
            .init(id: 2, name: "portobello mushroom", energy: 29),
            .init(id: 2, name: "eggplant", energy: 34.7),
            .init(id: 2, name: "banana", energy: 89.4),
            .init(id: 2, name: "olive oil", energy: 869.2),
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
    init(id: Int64, name: String, energy: Double) {
        self.init(
            id: id,
            name: name,
            energy: .init(kcal: energy),
            fatTotal: .zero,
            fatSaturated: .zero,
            protein: .zero,
            sodium: .zero,
            potassium: .zero,
            cholesterol: .zero,
            carbohydrates: .zero,
            fiber: .zero,
            sugar: .zero
        )
    }
}
