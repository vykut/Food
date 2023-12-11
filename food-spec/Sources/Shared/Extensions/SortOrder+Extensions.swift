import Foundation

public extension SortOrder {
    mutating func toggle() {
        self = switch self {
            case .forward: .reverse
            case .reverse: .forward
        }
    }
}
