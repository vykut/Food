import Foundation

public struct Recipe: Hashable, Codable, Sendable {
    public var id: Int64?
    public var name: String
    public var instructions: String
}
