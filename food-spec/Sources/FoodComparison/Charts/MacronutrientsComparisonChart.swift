import SwiftUI
import Charts
import Shared

struct MacronutrientsComparisonChart: View {
    let foods: [Food]

    var body: some View {
        Chart(foods, id: \.id) { food in
            ForEach(
                [
                    (name: "Protein", quantity: food.protein),
                    (name: "Carbohydrate", quantity: food.carbohydrate),
                    (name: "Fat", quantity: food.fatTotal)
                ],
                id: \.name
            ) { macronutrient in
                BarMark(
                    x: .value(macronutrient.name.capitalized, macronutrient.quantity),
                    y: .value("Name", summary(for: food))
                )
                .foregroundStyle(by: .value("Type", macronutrient.name.capitalized))
                .alignsMarkStylesWithPlotArea()
            }
        }
        .chartXAxis {
            AxisMarks(preset: .inset) {
                AxisGridLine()
                AxisValueLabel(
                    format: QuantityFormat.measurement(width: .abbreviated),
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
                foods.max(by: { $0.macronutrients < $1.macronutrients })!.macronutrients
            ]
        )
        .chartForegroundStyleScale(
            range: [.red, .yellow, .brown]
        )
        .chartLegend(spacing: 32)
    }

    private func summary(for food: Food) -> String {
"""
\(food.name.capitalized)
Total: \(food.macronutrients.formatted(width: .abbreviated)) | \
Protein: \(food.protein.formatted(width: .abbreviated)) | \
Carbohydrates: \(food.carbohydrate.formatted(width: .abbreviated)) | \
Fat: \(food.fatTotal.formatted(width: .abbreviated))
"""
    }
}

#Preview {
    MacronutrientsComparisonChart(
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

fileprivate extension Food {
    init(id: Int64, name: String, energy: Double, protein: Double, carbs: Double, fat: Double) {
        self.init(
            id: id,
            name: name,
            energy: .kcal(energy),
            fatTotal: .grams(fat),
            fatSaturated: .zero,
            protein: .grams(protein),
            sodium: .zero,
            potassium: .zero,
            cholesterol: .zero,
            carbohydrate: .grams(carbs),
            fiber: .zero,
            sugar: .zero
        )
    }
}
