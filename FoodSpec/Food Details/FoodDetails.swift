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
                        title: "Energy",
                        value: store.food.calories.measurement,
                        breakdown: []
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Protein",
                        value: store.food.protein.measurement,
                        breakdown: []
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Carbohydrates",
                        value: store.food.carbohydrates.measurement,
                        breakdown: [
                            .init(
                                title: "Fiber",
                                value: store.food.fiber.measurement
                            ),
                            .init(
                                title: "Sugar",
                                value: store.food.sugar.measurement
                            ),
                        ]
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Total Fat",
                        value: store.food.fatTotal.measurement,
                        breakdown: [
                            .init(
                                title: "Saturated Fat",
                                value: store.food.fatSaturated.measurement
                            )
                        ]
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Potassium",
                        value: store.food.potassium.measurement,
                        breakdown: []
                    )
                )

                NutritionalValueCard(
                    model: .init(
                        title: "Sodium",
                        value: store.food.sodium.measurement,
                        breakdown: []
                    )
                )
            } header: {
                Text(
                    "Nutritional values per \(Quantity(value: 100, unit: .grams).formatted(width: .wide))"
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
                food: .preview
            ),
            reducer: {
                FoodDetailsReducer()
            }
        )
    )
}
