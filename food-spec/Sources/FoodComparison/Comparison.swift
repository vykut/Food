import Foundation

public enum Comparison: String, Identifiable, Hashable, CaseIterable {
    case energy
    case protein
    case carbohydrate
    case fiber
    case sugar
    case fat
    case saturatedFat = "saturated fat"
    case cholesterol
    case potassium
    case sodium
    case macronutrients

    public var id: Self { self }
}
