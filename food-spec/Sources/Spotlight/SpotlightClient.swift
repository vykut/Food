import Foundation
import Dependencies
import DependenciesMacros
import Shared
@_exported import CoreSpotlight

@DependencyClient
public struct SpotlightClient {
    public var indexFoods: (_ foods: [Food]) async throws -> Void
}

extension SpotlightClient: DependencyKey {
    public static var liveValue: SpotlightClient = {
        let lock = ActorIsolated<Set<Food>>([])

        return .init(
            indexFoods: { foods in
                let previousFoods = await lock.value
                try Task.checkCancellation()

                let foodsSet = Set(foods)
                /// check if the new foods array is the same
                guard !foodsSet.subtracting(previousFoods).isEmpty else { return }

                guard CSSearchableIndex.isIndexingAvailable() else {
                    struct SpotlightIndexingNotAvailable: Error { }
                    throw SpotlightIndexingNotAvailable()
                }
                var searchableItems: [CSSearchableItem] = []
                for food in foods {
                    try Task.checkCancellation()
                    let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
                    attributeSet.displayName = food.name.capitalized
                    attributeSet.title = "\(food.name.capitalized) nutritional values"
                    attributeSet.contentDescription = food.nutritionalSummary
                    let searchableItem = CSSearchableItem(
                        uniqueIdentifier: food.name,
                        domainIdentifier: "foods",
                        attributeSet: attributeSet
                    )
                    searchableItems.append(searchableItem)
                }
                try await CSSearchableIndex.default().deleteAllSearchableItems()
                try await CSSearchableIndex.default().indexSearchableItems(searchableItems)
                await lock.setValue(foodsSet)
            }
        )
    }()

    public static let testValue: SpotlightClient = .init()
}

extension DependencyValues {
    public var spotlightClient: SpotlightClient {
        get { self[SpotlightClient.self ] }
        set { self[SpotlightClient.self ] = newValue }
    }
}
