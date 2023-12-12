import Foundation

public struct Food: Codable, Hashable, Sendable {
    public var id: Int64?
    public var name: String
    public var energy: Energy
    public var fatTotal: Quantity
    public var fatSaturated: Quantity
    public var protein: Quantity
    public var sodium: Quantity
    public var potassium: Quantity
    public var cholesterol: Quantity
    public var carbohydrate: Quantity
    public var fiber: Quantity
    public var sugar: Quantity

    public var nutritionalSummary: String {
        """
\(energy.formatted(width: .narrow)) | \
P: \(protein.formatted(width: .narrow)) | \
C: \(carbohydrate.formatted(width: .narrow)) | \
F: \(fatTotal.formatted(width: .narrow))
"""
    }

    public init(
        id: Int64? = nil,
        name: String,
        energy: Energy,
        fatTotal: Quantity,
        fatSaturated: Quantity,
        protein: Quantity,
        sodium: Quantity,
        potassium: Quantity,
        cholesterol: Quantity,
        carbohydrate: Quantity,
        fiber: Quantity,
        sugar: Quantity
    ) {
        self.id = id
        self.name = name
        self.energy = energy
        self.fatTotal = fatTotal
        self.fatSaturated = fatSaturated
        self.protein = protein
        self.sodium = sodium
        self.potassium = potassium
        self.cholesterol = cholesterol
        self.carbohydrate = carbohydrate
        self.fiber = fiber
        self.sugar = sugar
    }
}

public extension Food {
    enum SortingStrategy: String, Codable, Identifiable, Hashable, CaseIterable, Sendable {
        case name
        case energy
        case carbohydrates
        case protein
        case fat

        public var id: Self { self }
    }
}

public extension Food {
    static var preview: Self {
        preview(id: nil)
    }

    static func preview(id: Int64) -> Self {
        preview(id: Optional<Int64>.some(id))
    }

    private static func preview(id: Int64?) -> Self {
        .init(
            id: id,
            name: "eggplant",
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
