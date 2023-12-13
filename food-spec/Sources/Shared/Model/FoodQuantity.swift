import Foundation

public struct FoodQuantity: Hashable, Codable, Sendable {
    public var id: Int64?
    public var foodId: Int64
    public var quantity: Quantity
}
