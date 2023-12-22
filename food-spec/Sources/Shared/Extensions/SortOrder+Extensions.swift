import Foundation

public extension SortOrder {
    mutating func toggle() {
        self = toggled()
    }

    func toggled() -> Self {
        switch self {
            case .forward: .reverse
            case .reverse: .forward
        }
    }
}
