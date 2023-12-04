//
//  NutritionalValueCard.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 30/11/2023.
//

import SwiftUI

struct NutritionalValueCard<U: Dimension>: View {
    struct Model: Hashable {
        let title: String
        let value: Measurement<U>
        let breakdown: [Breakdown]

        struct Breakdown: Hashable {
            let title: String
            let value: Measurement<U>
        }
    }

    let model: Model

    var body: some View {
        VStack {
            LabeledContent(
                model.title,
                value: model.value,
                format: .measurement(width: .wide, usage: .asProvided)
            )
            .font(.title2)
            if !model.breakdown.isEmpty {
                Divider()
                ForEach(model.breakdown, id: \.self) { breakdown in
                    LabeledContent(
                        breakdown.title,
                        value: breakdown.value,
                        format: .measurement(width: .wide, usage: .asProvided)
                    )
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NutritionalValueCard<UnitMass>(
        model: .init(
            title: "Total Fat",
            value: .init(value: 1.5, unit: .grams),
            breakdown: [
                .init(
                    title: "Saturated Fat",
                    value: .init(value: 0, unit: .grams)
                ),
                .init(
                    title: "Trans Fat",
                    value: .init(value: 0, unit: .grams)
                ),
            ]
        )
    )
        .padding()
}
