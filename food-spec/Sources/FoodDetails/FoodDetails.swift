import SwiftUI
import ComposableArchitecture
import Shared
import QuantityPicker

public struct FoodDetails: View {
    @Bindable var store: StoreOf<FoodDetailsFeature>

    public init(store: StoreOf<FoodDetailsFeature>) {
        self.store = store
    }

    public var body: some View {
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
        .scrollDismissesKeyboard(.immediately)
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
        GroupBox {
            EnergyBreakdownChart(
                food: store.food
            )
            .frame(height: 150)
            .padding(.top)
        } label: {
            Text("Energy Breakdown")
                .font(.title2)
            Divider()
        }
    }

    var header: some View {
        GroupBox {
            QuantityPicker(
                store: store.scope(state: \.quantityPicker, action: \.quantityPicker)
            )
        }
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
