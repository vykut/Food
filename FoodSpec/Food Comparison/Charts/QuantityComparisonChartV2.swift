//
//  QuantityComparisonChartV2.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 10/12/2023.
//

import SwiftUI
import Charts

struct QuantityComparison: Identifiable, Hashable {
    let name: String
    let quantities: [Quantities]

    var id: String { name }

    var total: Quantity {
        quantities.reduce(.zero) {
            $0 + $1.quantity
        }
    }

    struct Quantities: Identifiable, Hashable {
        let name: String
        let quantity: Quantity
        let color: Color

        var id: String { name }
    }
}

struct QuantityComparisonChartV2: View {
    let comparisons: [QuantityComparison]

    var body: some View {
        Chart(comparisons) { comparison in
            ForEach(comparison.quantities) { quantity in
                BarMark(
                    x: .value(quantity.name.capitalized, quantity.quantity),
                    y: .value("Name", summary(for: comparison))
                )
                .foregroundStyle(by: .value("Type", quantity.name.capitalized))
                .alignsMarkStylesWithPlotArea()
            }
        }
        .chartXAxis {
            AxisMarks(preset: .inset) {
                AxisGridLine()
                AxisValueLabel(
                    format: QuantityFormat.measurement(width: .abbreviated, usage: .asProvided),
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
                Quantity.zero,
                comparisons.max(by: { $0.total < $1.total })!.total
            ]
        )
        .chartForegroundStyleScale(
            range: comparisons[0].quantities.map(\.color)
        )
        .chartLegend(comparisons.count > 1 ? .visible : .hidden)
        .chartLegend(spacing: 32)
    }

    private func summary(for comparison: QuantityComparison) -> String {
        var string = comparison.name.capitalized
        string += "\n"
        string += "Total: \(comparison.total.formatted(width: .abbreviated)) | "
        for quantity in comparison.quantities {
            string += "\(quantity.name): \(quantity.quantity.formatted(width: .abbreviated))"
            if quantity != comparison.quantities.last {
                string += " | "
            }
        }
        return string
    }
}

#Preview {
    QuantityComparisonChartV2(
        comparisons: [
            QuantityComparison(
                name: "Lettuce",
                quantities: [
                    .init(
                        name: "Protein",
                        quantity: .init(grams: 1.2),
                        color: .red
                    ),
                    .init(
                        name: "Carbohydrates",
                        quantity: .init(grams: 3.3),
                        color: .yellow
                    ),
                    .init(
                        name: "Fat",
                        quantity: .init(grams: 0.3),
                        color: .brown
                    ),
                ]
            ),
            QuantityComparison(
                name: "Strawberry",
                quantities: [
                    .init(
                        name: "Protein",
                        quantity: .init(grams: 0.7),
                        color: .red
                    ),
                    .init(
                        name: "Carbohydrates",
                        quantity: .init(grams: 7.7),
                        color: .yellow
                    ),
                    .init(
                        name: "Fat",
                        quantity: .init(grams: 0.3),
                        color: .brown
                    ),
                ]
            ),
            QuantityComparison(
                name: "Banana",
                quantities: [
                    .init(
                        name: "Protein",
                        quantity: .init(grams: 1.1),
                        color: .red
                    ),
                    .init(
                        name: "Carbohydrates",
                        quantity: .init(grams: 23.2),
                        color: .yellow
                    ),
                    .init(
                        name: "Fat",
                        quantity: .init(grams: 0.3),
                        color: .brown
                    ),
                ]
            ),
            QuantityComparison(
                name: "Ribeye",
                quantities: [
                    .init(
                        name: "Protein",
                        quantity: .init(grams: 24.8),
                        color: .red
                    ),
                    .init(
                        name: "Carbohydrates",
                        quantity: .init(grams: 0),
                        color: .yellow
                    ),
                    .init(
                        name: "Fat",
                        quantity: .init(grams: 18.9),
                        color: .brown
                    ),
                ]
            ),
        ]
    )
    .padding()
}

fileprivate extension Food {
    init(id: Int64, name: String, quantity: Double) {
        let quantity = Quantity(grams: quantity)
        self.init(
            id: id,
            name: name,
            energy: .zero,
            fatTotal: quantity,
            fatSaturated: quantity,
            protein: quantity,
            sodium: quantity,
            potassium: quantity,
            cholesterol: quantity,
            carbohydrates: quantity,
            fiber: quantity,
            sugar: quantity
        )
    }
}
