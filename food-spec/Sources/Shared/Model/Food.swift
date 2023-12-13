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

    public enum CodingKeys: CodingKey {
        case id
        case name
        case energy
        case fatTotal
        case fatSaturated
        case protein
        case sodium
        case potassium
        case cholesterol
        case carbohydrate
        case fiber
        case sugar
    }
}
