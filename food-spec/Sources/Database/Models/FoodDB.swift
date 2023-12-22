import Foundation
import GRDB

struct FoodDB: Hashable, Codable {
    var id: Int64?
    var name: String
    var energy: Double
    var fatTotal: Double
    var fatSaturated: Double
    var protein: Double
    var sodium: Double
    var potassium: Double
    var cholesterol: Double
    var carbohydrate: Double
    var fiber: Double
    var sugar: Double
}

extension FoodDB: FetchableRecord, MutablePersistableRecord {
    static let ingredients = hasMany(IngredientDB.self).forKey("ingredients")
    static let meals = hasMany(MealDB.self, through: ingredients, using: IngredientDB.meal).forKey("meals") // has not been tested

    var ingredients: QueryInterfaceRequest<IngredientDB> {
        request(for: Self.ingredients)
    }

    var meals: QueryInterfaceRequest<MealDB> {
        request(for: Self.meals)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension FoodDB {
    enum Columns {
        static let name = Column(CodingKeys.name)
        static let energy = Column(CodingKeys.energy)
        static let fatTotal = Column(CodingKeys.fatTotal)
        static let fatSaturated = Column(CodingKeys.fatSaturated)
        static let protein = Column(CodingKeys.protein)
        static let sodium = Column(CodingKeys.sodium)
        static let potassium = Column(CodingKeys.potassium)
        static let cholesterol = Column(CodingKeys.cholesterol)
        static let carbohydrate = Column(CodingKeys.carbohydrate)
        static let fiber = Column(CodingKeys.fiber)
        static let sugar = Column(CodingKeys.sugar)
    }
}
