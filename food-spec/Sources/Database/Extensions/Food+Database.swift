import Foundation
import Shared
import GRDB

extension Food: FetchableRecord, MutablePersistableRecord {
    static let foodQuantities = hasMany(FoodQuantityDB.self).forKey("foodQuantities")
    static let recipes = hasMany(RecipeDB.self, through: foodQuantities, using: FoodQuantityDB.recipe)

    var foodQuantities: QueryInterfaceRequest<FoodQuantityDB> {
        request(for: Self.foodQuantities)
    }

    var recipes: QueryInterfaceRequest<RecipeDB> {
        request(for: Self.recipes)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension Food {
    public enum Columns {
        public static let id = Column(Food.CodingKeys.id)
        public static let name = Column(Food.CodingKeys.name)
        public static let energy = Column(Food.CodingKeys.energy)
        public static let fatTotal = Column(Food.CodingKeys.fatTotal)
        public static let protein = Column(Food.CodingKeys.protein)
        public static let sodium = Column(Food.CodingKeys.sodium)
        public static let potassium = Column(Food.CodingKeys.potassium)
        public static let cholesterol = Column(Food.CodingKeys.cholesterol)
        public static let carbohydrate = Column(Food.CodingKeys.carbohydrate)
        public static let fiber = Column(Food.CodingKeys.fiber)
        public static let sugar = Column(Food.CodingKeys.sugar)
    }
}
