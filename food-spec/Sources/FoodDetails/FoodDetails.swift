//
//  FoodDetails.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 30/11/2023.
//

import SwiftUI
import ComposableArchitecture
import Shared

struct FoodDetails: View {
    @Bindable var store: StoreOf<FoodDetailsFeature>

    var body: some View {
        ScrollView {
            Section {
                energy
                protein
                carbohydrates
                fat
                cholesterol
                potassium
                sodium
                energyBreakdown
            } header: {
                header
            }
            .padding(.horizontal)
        }
        .navigationTitle(store.food.name.capitalized)
    }

    var energy: some View {
        NutritionalValueCard(
            model: .init(
                title: "Energy",
                value: store.food.energy.measurement,
                breakdown: []
            )
        )
    }

    var protein: some View {
        NutritionalValueCard(
            model: .init(
                title: "Protein",
                value: store.food.protein.measurement,
                breakdown: []
            )
        )
    }

    var carbohydrates: some View {
        NutritionalValueCard(
            model: .init(
                title: "Carbohydrate",
                value: store.food.carbohydrate.measurement,
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
    }

    var fat: some View {
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
    }

    var cholesterol: some View {
        NutritionalValueCard(
            model: .init(
                title: "Cholesterol",
                value: store.food.cholesterol.measurement.converted(to: .milligrams),
                breakdown: []
            )
        )
    }

    var potassium: some View {
        NutritionalValueCard(
            model: .init(
                title: "Potassium",
                value: store.food.potassium.measurement.converted(to: .milligrams),
                breakdown: []
            )
        )
    }

    var sodium: some View {
        NutritionalValueCard(
            model: .init(
                title: "Sodium",
                value: store.food.sodium.measurement.converted(to: .milligrams),
                breakdown: []
            )
        )
    }

    var energyBreakdown: some View {
        VStack(alignment: .leading) {
            Text("Energy Breakdown")
            .font(.title2)
            Divider()
            EnergyBreakdownChart(
                food: store.food
            )
            .frame(height: 150)
            .padding(.top)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    var header: some View {
        Text(
            "Nutritional values per \(Quantity(value: 100, unit: .grams).formatted(width: .wide))"
        )
        .font(.title2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    FoodDetails(
        store: Store(
            initialState: .init(
                food: .preview
            ),
            reducer: {
                FoodDetailsFeature()
            }
        )
    )
}