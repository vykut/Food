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
