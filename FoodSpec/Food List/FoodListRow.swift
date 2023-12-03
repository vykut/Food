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
        HStack {
            Text(food.name.capitalized)
            Spacer()
            HStack {
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
    let modelContainer = try! ModelContainer(for: Food.self)
    return FoodListRow(
        food: .preview
    )
    .padding()
}
