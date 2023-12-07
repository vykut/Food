//
//  SpotlightClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 07/12/2023.
//

import Foundation
import CoreSpotlight
import ComposableArchitecture

@DependencyClient
struct SpotlightClient {
    var indexFoods: (_ foods: [Food]) async throws -> Void
}

extension SpotlightClient: DependencyKey {
    static var liveValue: SpotlightClient = .init(
        indexFoods: { foods in
            guard CSSearchableIndex.isIndexingAvailable() else {
                struct SpotlightIndexingNotAvailable: Error { }
                throw SpotlightIndexingNotAvailable()
            }
            var searchableItems: [CSSearchableItem] = []
            for food in foods {
                let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
                attributeSet.displayName = "\(food.name.capitalized) nutritional values"
                let searchableItem = CSSearchableItem(
                    uniqueIdentifier: food.name,
                    domainIdentifier: "foods",
                    attributeSet: attributeSet
                )
                searchableItems.append(searchableItem)
            }
            try await CSSearchableIndex.default().deleteAllSearchableItems()
            try await CSSearchableIndex.default().indexSearchableItems(searchableItems)
        }
    )
}

extension DependencyValues {
    var spotlightClient: SpotlightClient {
        get { self[SpotlightClient.self ] }
        set { self[SpotlightClient.self ] = newValue }
    }
}
