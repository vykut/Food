//
//  FoodDetail.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 30/11/2023.
//

import SwiftUI

struct FoodDetail: View {
    let food: Food

    var body: some View {
        let _ = Self._printChanges()
        ScrollView {
            Section {
                NutritionalValueCard(
                    model: .init(
                        title: "Protein",
                        value: food.protein,
                        breakdown: []
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Carbohydrates",
                        value: food.carbohydrates,
                        breakdown: [
                            .init(
                                title: "Fiber",
                                value: food.fiber
                            ),
                            .init(
                                title: "Sugar",
                                value: food.sugar
                            ),
                        ]
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Total Fat",
                        value: food.fatTotal,
                        breakdown: [
                            .init(
                                title: "Saturated Fat",
                                value: food.fatSaturated
                            )
                        ]
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Potassium",
                        value: food.potassium,
                        breakdown: []
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Sodium",
                        value: food.sodium,
                        breakdown: []
                    )
                )
            } header: {
                Text(
                    "Nutritional values per \(Quantity(value: 100, unit: .grams).formatted(.measurement(width: .wide, usage: .asProvided)))"
                )
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
        }
        .navigationTitle(food.name.capitalized)
    }
}

#Preview {
    FoodDetail(
        food: .init(
            name: "eggplant",
            openDate: .now,
            calories: 34.7,
            fatTotal: .init(value: 0.2, unit: .grams),
            fatSaturated: .init(value: 0.0, unit: .grams),
            protein: .init(value: 0.8, unit: .grams),
            sodium: .init(value: 0.0, unit: .milligrams),
            potassium: .init(value: 15.0, unit: .milligrams),
            cholesterol: .init(value: 0.0, unit: .milligrams),
            carbohydrates: .init(value: 8.7, unit: .grams),
            fiber: .init(value: 2.5, unit: .grams),
            sugar: .init(value: 3.2, unit: .grams)
        )
    )
}
