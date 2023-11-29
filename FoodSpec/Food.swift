//
//  Item.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import Foundation
import SwiftData

@Model
final class Food {
    @Attribute(.unique) let fdcId: Int
    @Attribute(.unique) let fnddsId: Int
    var name: String
    var scientificName: String
    var ingredients: String
    var additionalDescriptions: String

    init(fdcId: Int, fnddsId: Int, name: String, scientificName: String, ingredients: String, additionalDescriptions: String) {
        self.fdcId = fdcId
        self.fnddsId = fnddsId
        self.name = name
        self.scientificName = scientificName
        self.ingredients = ingredients
        self.additionalDescriptions = additionalDescriptions
    }
}
