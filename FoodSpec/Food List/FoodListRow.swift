//
//  FoodListRow.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 03/12/2023.
//

import SwiftUI
import SwiftData

struct FoodListRow: View {
    let food: Food

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(food.name.capitalized)
            HStack {
                Text(food.energy.formatted(width: .narrow))
                Text("P: \(food.protein.formatted(width: .narrow))")
                Text("C: \(food.carbohydrates.formatted(width: .narrow))")
                Text("F: \(food.fatTotal.formatted(width: .narrow))")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    FoodListRow(
        food: .preview
    )
    .padding()
}
