import Foundation
import Shared

public struct UserPreferences: Codable, Hashable {
    public var recentSearchesSortingStrategy: Food.SortingStrategy?
    public var recentSearchesSortingOrder: SortOrder?
}
