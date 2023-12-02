//
//  FoodDetails.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 30/11/2023.
//

import SwiftUI
import ComposableArchitecture

struct FoodDetails: View {
    @Bindable var store: StoreOf<FoodDetailsReducer>

    var body: some View {
        ScrollView {
            Section {
                NutritionalValueCard(
                    model: .init(
                        title: "Protein",
                        value: store.food.protein,
                        breakdown: []
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Carbohydrates",
                        value: store.food.carbohydrates,
                        breakdown: [
                            .init(
                                title: "Fiber",
                                value: store.food.fiber
                            ),
                            .init(
                                title: "Sugar",
                                value: store.food.sugar
                            ),
                        ]
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Total Fat",
                        value: store.food.fatTotal,
                        breakdown: [
                            .init(
                                title: "Saturated Fat",
                                value: store.food.fatSaturated
                            )
                        ]
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Potassium",
                        value: store.food.potassium,
                        breakdown: []
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Sodium",
                        value: store.food.sodium,
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
        .navigationTitle(store.food.name.capitalized)
    }
}

#Preview {
    FoodDetails(
        store: Store(
            initialState: .init(
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
            ),
            reducer: {
                FoodDetailsReducer()
            }
        )
    )
}
