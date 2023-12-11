import SwiftUI
import Charts
import Shared

struct QuantityComparisonChart: View {
    let foods: [Food]
    let keyPath: KeyPath<Food, Quantity>
    let name: String
    let color: Color

    var body: some View {
        Chart(foods, id: \.id) { food in
            let quantity = food[keyPath: keyPath]
            BarMark(
                x: .value(name, quantity),
                y: .value("Name", "\(food.name.capitalized)\n\(quantity.formatted(width: .abbreviated, usage: .asProvided))")
            )
            .foregroundStyle(by: .value("Type", name))
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
            range: [color]
        )
        .chartLegend(.hidden)
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
        keyPath: \.potassium,
        name: "Potassium",
        color: .purple
    )
    .padding()
}

extension Quantity: Plottable {
    public var primitivePlottable: Double {
        value
    }

    public init?(primitivePlottable: Double) {
        self = .grams(primitivePlottable)
    }
}

fileprivate extension Food {
    init(id: Int64, name: String, quantity: Double) {
        let quantity = Quantity.grams(quantity)
        self.init(
            id: id,
            name: name,
            energy: .zero,
            fatTotal: quantity,
            fatSaturated: quantity,
            protein: quantity,
            sodium: quantity.converted(to: .milligrams),
            potassium: quantity.converted(to: .milligrams),
            cholesterol: quantity.converted(to: .milligrams),
            carbohydrate: quantity,
            fiber: quantity,
            sugar: quantity
        )
    }
}
