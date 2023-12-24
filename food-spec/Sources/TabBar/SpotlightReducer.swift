import Foundation
import Shared
import Spotlight
import Database
import ComposableArchitecture
import RegexBuilder

@Reducer
public struct SpotlightReducer: Sendable {
    public struct State: Hashable {

    }

    public enum Action {
        case start
        case handleSelectedItem(NSUserActivity)
        case handleSearchInApp(NSUserActivity)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate {
            case showFoodDetails(Food)
            case showMealDetails(Meal)
            case searchFood(String)
        }
    }

    @Dependency(\.spotlightClient) private var spotlightClient
    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .start:
                    return .merge(
                        .run { _ in
                            let observation = databaseClient.observeFoods(sortedBy: .name, order: .forward)
                            for await foods in observation {
                                try await spotlightClient.index(foods: foods)
                            }
                        },
                        .run { _ in
                            let observation = databaseClient.observeMeals(sortedBy: .name, order: .forward)
                            for await meals in observation {
                                try await spotlightClient.index(meals: meals)
                            }
                        }
                    )

                case .handleSelectedItem(let activity):
                    let identifierPattern = Regex {
                        Capture {
                            ChoiceOf {
                                "foodId"
                                "mealId"
                            }
                        }
                        ":"
                        Capture {
                            OneOrMore(.digit)
                        }
                    }
                    guard 
                        let identifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                        let match = identifier.firstMatch(of: identifierPattern),
                        let id = Int64(match.output.2)
                    else { return .none }
                    let domain = match.output.1
                    switch domain {
                        case "foodId":
                            return .run { send in
                                guard let food = try await databaseClient.getFood(id: id) else { return }
                                await send(.delegate(.showFoodDetails(food)))
                            }
                        case "mealId":
                            return .run { send in
                                guard let meal = try await databaseClient.getMeal(id: id) else { return }
                                await send(.delegate(.showMealDetails(meal)))
                            }
                        default:
                            assertionFailure("Unknown item selected")
                            return .none
                    }

                case .handleSearchInApp(let activity):
                    guard let searchString = activity.userInfo?[CSSearchQueryString] as? String else { return .none }
                    return .send(.delegate(.searchFood(searchString)))

                case .delegate:
                    return .none
            }
        }
    }
}
