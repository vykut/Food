import Foundation

public extension Food {
    var nutritionalSummary: String {
        """
\(energy.formatted(width: .narrow)) | \
P: \(protein.formatted(width: .narrow)) | \
C: \(carbohydrate.formatted(width: .narrow)) | \
F: \(fatTotal.formatted(width: .narrow))
"""
    }
}

public extension Food {
    @available(*, unavailable, message: "once a food's quantities are mutated, further mutations will not be based on the serving size of 100g. It's not possible to come back to the original serving size")
    mutating func changeServingSize(to quantity: Quantity) {
        self = changingServingSize(to: quantity)
    }

    func changingServingSize(to quantity: Quantity) -> Self {
        let quantityInGrams = quantity.converted(to: .grams)
        let ratio = quantityInGrams.value / 100

        return  .init(
            id: self.id,
            name: self.name,
            energy: self.energy * ratio,
            fatTotal: self.fatTotal * ratio,
            fatSaturated: self.fatSaturated * ratio,
            protein: self.protein * ratio,
            sodium: self.sodium * ratio,
            potassium: self.potassium * ratio,
            cholesterol: self.cholesterol * ratio,
            carbohydrate: self.carbohydrate * ratio,
            fiber: self.fiber * ratio,
            sugar: self.sugar * ratio
        )
    }
}

public extension Food {
    enum SortStrategy: String, Codable, Identifiable, Hashable, CaseIterable, Sendable {
        case name
        case energy
        case carbohydrate
        case protein
        case fat

        public var id: Self { self }
    }
}

public extension Food {
    static var preview: Self {
        preview(id: nil)
    }

    static func preview(id: Int64, name: String = "eggplant") -> Self {
        preview(id: Optional<Int64>.some(id), name: name)
    }

    private static func preview(id: Int64?, name: String = "eggplant") -> Self {
        .init(
            id: id,
            name: name,
            energy: .init(value: 34.7, unit: .kilocalories),
            fatTotal: .init(value: 0.2, unit: .grams),
            fatSaturated: .init(value: 0.0, unit: .grams),
            protein: .init(value: 0.8, unit: .grams),
            sodium: .init(value: 0.0, unit: .milligrams),
            potassium: .init(value: 15.0, unit: .milligrams),
            cholesterol: .init(value: 0.0, unit: .milligrams),
            carbohydrate: .init(value: 8.7, unit: .grams),
            fiber: .init(value: 2.5, unit: .grams),
            sugar: .init(value: 3.2, unit: .grams)
        )
    }
}
