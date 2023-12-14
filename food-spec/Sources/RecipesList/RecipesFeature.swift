import Foundation
import Shared
import Database
import ComposableArchitecture

@Reducer
public struct RecipesFeature {
    @ObservableState
    public struct State: Hashable {
        var recipes: [Recipe] = []

        public init() { }
    }

    @CasePathable
    public enum Action {
        case plusButtonTapped
        case onTask
        case onRecipesUpdate([Recipe])
        case onDelete(IndexSet)
    }

    public init() { }

    @Dependency(\.databaseClient) private var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                    // FIXME: Remove this
                case .plusButtonTapped:
                    return .run { [databaseClient] send in
                        _ = try await databaseClient.insert(
                            recipe: .init(
                                name: Date().formatted(),
                                foodQuantities: [
                                    .init(food: .preview(id: 1), quantity: .grams(100)),
                                    .init(food: .preview(id: 2), quantity: .grams(200)),
                                    .init(food: .preview(id: 3), quantity: .init(value: 15, unit: .pounds)),
                                ],
                                instructions: "empty"
                            ))
                    }
                case .onTask:
                    return .run { [databaseClient] send in
                        let stream = databaseClient.observeRecipes()
                        for await recipes in stream {
                            await send(.onRecipesUpdate(recipes), animation: .default)
                        }
                    }

                case .onRecipesUpdate(let recipes):
                    state.recipes = recipes
                    // handle empty recipes
                    return .none

                case .onDelete(let indices):
                    return .run { [recipes = state.recipes, databaseClient] send in
                        let recipesToDelete = indices.map { recipes[$0] }
                        for recipe in recipesToDelete {
                            try await databaseClient.delete(recipe: recipe)
                        }
                    }
            }
        }
    }
}
