import Foundation
import Shared

public struct UserPreferences: Codable, Hashable {
    public var recentSearchesSortingStrategy: String?
    public var recentSearchesSortingOrder: SortOrder?
}
