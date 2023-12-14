import Foundation
import GRDB
import Shared

extension Recipe: FetchableRecord {
    public init(row: Row) throws {
        try self.init(
            id: row["id"],
            name: row["name"],
            quantities: row.prefetchedRows["quantities"]?.map(FoodQuantity.init) ?? [],
            instructions: row["instructions"]
        )
    }

    init(recipeDb: RecipeDB, quantities: [(FoodQuantityDB, FoodDB)]) throws {
        try self.init(
            id: recipeDb.id,
            name: recipeDb.name,
            quantities: quantities.map(FoodQuantity.init),
            instructions: recipeDb.instructions
        )
    }
}

extension RecipeDB {
    init(recipe: Recipe) {
        self.init(
            id: recipe.id,
            name: recipe.name,
            instructions: recipe.instructions
        )
    }
}
