import Foundation

public struct Food: Hashable, Sendable {
    public typealias ID = Int64?

    public var id: ID
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

    public init(
        id: ID = nil,
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
