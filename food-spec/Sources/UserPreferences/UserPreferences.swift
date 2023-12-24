import Foundation
import Shared

public struct UserPreferences: Codable, Hashable {
    public var recentSearchesSortStrategy: Food.SortStrategy?
    public var recentSearchesSortOrder: SortOrder?
}
