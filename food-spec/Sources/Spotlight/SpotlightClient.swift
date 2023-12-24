import Foundation
import Dependencies
import DependenciesMacros
import Shared
@_exported import CoreSpotlight

@DependencyClient
public struct SpotlightClient: Sendable {
    @DependencyEndpoint(method: "index")
    public var indexFoods: (_ foods: [Food]) async throws -> Void
    @DependencyEndpoint(method: "index")
    public var indexMeals: (_ meals: [Meal]) async throws -> Void
}

extension SpotlightClient: DependencyKey {
    public static var liveValue: SpotlightClient = {
        let foodsLock = ActorIsolated<Set<Food>>([])
        let mealsLock = ActorIsolated<Set<Meal>>([])

        @Sendable func checkIndexingAvailable() throws {
            guard CSSearchableIndex.isIndexingAvailable() else {
                struct SpotlightIndexingNotAvailable: Error { }
                throw SpotlightIndexingNotAvailable()
            }
        }

        let searchableIndex = { CSSearchableIndex.default() }

        return .init(
            indexFoods: { foods in
                let previousFoods = await foodsLock.value
                try Task.checkCancellation()

                let foodsSet = Set(foods)
                /// check if the new foods array is the same
                guard !foodsSet.symmetricDifference(previousFoods).isEmpty else { return }

                try checkIndexingAvailable()
                var searchableItems: [CSSearchableItem] = []
                for food in foods {
                    try Task.checkCancellation()
                    let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
                    attributeSet.displayName = food.name.capitalized
                    attributeSet.title = "\(food.name.capitalized) nutritional values"
                    attributeSet.contentDescription = food.nutritionalSummary
                    let searchableItem = CSSearchableItem(
                        uniqueIdentifier: food.id.map { "foodId:\($0)" },
                        domainIdentifier: "foods",
                        attributeSet: attributeSet
                    )
                    searchableItems.append(searchableItem)
                }
                try await searchableIndex().deleteSearchableItems(withDomainIdentifiers: ["foods"])
                try await searchableIndex().indexSearchableItems(searchableItems)
                await foodsLock.setValue(foodsSet)
            },
            indexMeals: { meals in
                let previousMeals = await mealsLock.value
                try Task.checkCancellation()

                let mealsSet = Set(meals)

                /// check if the new meals array is the same
                guard !mealsSet.symmetricDifference(previousMeals).isEmpty else { return }

                @Dependency(\.nutritionalValuesCalculator) var calculator

                try checkIndexingAvailable()
                var searchableItems: [CSSearchableItem] = []
                for meal in meals {
                    let hasServings = meal.servings != 1
                    let nutritionalValues = if hasServings {
                        calculator.nutritionalValuesPerServing(meal: meal)
                    } else {
                        calculator.nutritionalValues(meal: meal)
                    }
                    let summary = nutritionalValues.foodWithQuantity.nutritionalSummary
                    let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
                    attributeSet.displayName = meal.name.capitalized
                    attributeSet.title = "\(meal.name.capitalized) nutritional values"
                    attributeSet.contentDescription = hasServings ? "Per serving: \(summary)" : summary
                    let searchableItem = CSSearchableItem(
                        uniqueIdentifier: meal.id.map { "mealId:\($0)" },
                        domainIdentifier: "meals",
                        attributeSet: attributeSet
                    )
                    searchableItems.append(searchableItem)
                }
                try await searchableIndex().deleteSearchableItems(withDomainIdentifiers: ["meals"])
                try await searchableIndex().indexSearchableItems(searchableItems)
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
