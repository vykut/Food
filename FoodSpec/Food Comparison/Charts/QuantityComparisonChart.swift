//
//  QuantityComparisonChart.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 10/12/2023.
//

import SwiftUI
import Charts

struct QuantityComparisonChart: View {
    let foods: [Food]
    let keyPath: KeyPath<Food, Quantity>

    var body: some View {
        Chart(foods, id: \.id) { food in
            let quantity = food[keyPath: keyPath]
            BarMark(
                x: .value(quantityName, quantity),
                y: .value("Name", "\(food.name.capitalized)\n\(quantity.formatted(width: .abbreviated, usage: .asProvided))")
            )
            .foregroundStyle(by: .value("Type", quantityName))
            .alignsMarkStylesWithPlotArea()
        }
        .chartXAxis {
            AxisMarks(preset: .inset) { value in
                let quantity = value.as(Quantity.self)!
                let plottableQuantity = Quantity(value: quantity.value, unit: foods.first![keyPath: keyPath].unit)
                AxisGridLine()
                AxisValueLabel(plottableQuantity.formatted(width: .abbreviated, usage: .asProvided), anchor: .top)
            }
        }
        .chartYAxis {
            AxisMarks(preset: .inset) {
                AxisValueLabel()
            }
        }
        .chartXScale(
            domain: [
                .init(value: 0, unit: foods.first![keyPath: keyPath].unit),
                foods.max(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })![keyPath: keyPath]
            ]
        )
        .chartForegroundStyleScale(
            range: [barColor]
        )
        .chartLegend(.hidden)
    }

    private var barColor: some ShapeStyle {
        switch keyPath {
            case \.protein: Color.red
            case \.carbohydrate: Color.yellow
            case \.fatTotal: Color.brown
            case \.potassium: Color.purple
            case \.sodium: Color.mint
            case \.cholesterol: Color.orange
            default: fatalError("Unhandled keyPath")
        }
    }

    private var quantityName: String {
        switch keyPath {
            case \.protein: "Protein"
            case \.carbohydrate: "Carbohydrate"
            case \.fatTotal: "Fat"
            case \.potassium: "Potassium"
            case \.sodium: "Sodium"
            case \.cholesterol: "Cholesterol"
            default: fatalError("Unhandled keyPath")
        }
    }
}

#Preview {
    QuantityComparisonChart(
        foods: [
            .init(id: 1, name: "lettuce", quantity: 17),
            .init(id: 2, name: "asparagus", quantity: 21.4),
            .init(id: 2, name: "mushroom", quantity: 28),
            .init(id: 2, name: "portobello mushroom", quantity: 29),
            .init(id: 2, name: "eggplant", quantity: 34.7),
            .init(id: 2, name: "banana", quantity: 89.4),
            .init(id: 2, name: "olive oil", quantity: 869.2),
        ],
        keyPath: \.potassium
    )
    .padding()
}

extension Quantity: Plottable {
    var primitivePlottable: Double {
        value
    }

    init?(primitivePlottable: Double) {
        self.init(grams: primitivePlottable)
    }
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
            carbohydrate: quantity,
            fiber: quantity,
            sugar: quantity
        )
    }
}
