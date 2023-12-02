//
//  Item.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import Foundation
import SwiftData

typealias Quantity = Measurement<UnitMass>

//@Model
/* final class */ struct Food: Hashable, Identifiable {
    /* @Attribute(.unique) */ let name: String
    let openDate: Date
    let calories: Double
    /* @Attribute(.transformable(by: QuantityTransformer.self)) */ let fatTotal: Quantity
    /* @Attribute(.transformable(by: QuantityTransformer.self)) */ let fatSaturated: Quantity
    /* @Attribute(.transformable(by: QuantityTransformer.self)) */ let protein: Quantity
    /* @Attribute(.transformable(by: QuantityTransformer.self)) */ let sodium: Quantity
    /* @Attribute(.transformable(by: QuantityTransformer.self)) */ let potassium: Quantity
    /* @Attribute(.transformable(by: QuantityTransformer.self)) */ let cholesterol: Quantity
    /* @Attribute(.transformable(by: QuantityTransformer.self)) */ let carbohydrates: Quantity
    /* @Attribute(.transformable(by: QuantityTransformer.self)) */ let fiber: Quantity
    /* @Attribute(.transformable(by: QuantityTransformer.self)) */ let sugar: Quantity

    var id: String { name }
}

extension Food {
    init(foodApiModel: FoodApiModel, date: Date) {
        self.init(
            name: foodApiModel.name,
            openDate: date,
            calories: foodApiModel.calories,
            fatTotal: .init(value: foodApiModel.fatTotalG, unit: .grams),
            fatSaturated: .init(value: foodApiModel.fatSaturatedG, unit: .grams),
            protein: .init(value: foodApiModel.proteinG, unit: .grams),
            sodium: .init(value: foodApiModel.sodiumMg, unit: .milligrams),
            potassium: .init(value: foodApiModel.potassiumMg, unit: .milligrams),
            cholesterol: .init(value: foodApiModel.cholesterolMg, unit: .milligrams),
            carbohydrates: .init(value: foodApiModel.carbohydratesTotalG, unit: .grams),
            fiber: .init(value: foodApiModel.fiberG, unit: .grams),
            sugar: .init(value: foodApiModel.sugarG, unit: .grams)
        )
    }
}

final class QuantityTransformer: ValueTransformer {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let mass = value as? Quantity else { return nil }
        return try? encoder.encode(mass) as NSData
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        let measurement = try? decoder.decode(Quantity.self, from: data as Data)
        return measurement
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }
}

extension NSValueTransformerName {
    static let quantityTransformerName = NSValueTransformerName(rawValue: "QuantityTransformer")
}
