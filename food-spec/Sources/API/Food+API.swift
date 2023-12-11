import Shared

public extension Food {
    init(foodApiModel: FoodApiModel) {
        self.init(
            id: nil,
            name: foodApiModel.name,
            energy: .init(value: foodApiModel.calories, unit: .kilocalories),
            fatTotal: .init(value: foodApiModel.fatTotalG, unit: .grams),
            fatSaturated: .init(value: foodApiModel.fatSaturatedG, unit: .grams),
            protein: .init(value: foodApiModel.proteinG, unit: .grams),
            sodium: .init(value: foodApiModel.sodiumMg, unit: .milligrams),
            potassium: .init(value: foodApiModel.potassiumMg, unit: .milligrams),
            cholesterol: .init(value: foodApiModel.cholesterolMg, unit: .milligrams),
            carbohydrate:  .init(value: foodApiModel.carbohydratesTotalG, unit: .grams),
            fiber: .init(value: foodApiModel.fiberG, unit: .grams),
            sugar: .init(value: foodApiModel.sugarG, unit: .grams)
        )
    }
}
