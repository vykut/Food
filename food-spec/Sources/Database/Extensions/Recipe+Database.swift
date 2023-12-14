import Foundation
import GRDB
import Shared

extension Recipe: FetchableRecord {
    public init(row: Row) throws {
        try self.init(
            id: row["id"],
            name: row["name"],
            ingredients: row.prefetchedRows["ingredients"]?.map(Ingredient.init) ?? [],
            instructions: row["instructions"]
        )
    }

    init(recipeDb: RecipeDB, ingredients: [(IngredientDB, FoodDB)]) throws {
        try self.init(
            id: recipeDb.id,
            name: recipeDb.name,
            ingredients: ingredients.map(Ingredient.init),
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
