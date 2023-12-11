//
//  Comparison.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 10/12/2023.
//

import Foundation

enum Comparison: String, Identifiable, Hashable, CaseIterable {
    case energy
    case protein
    case carbohydrate
    case fiber
    case sugar
    case fat
    case saturatedFat = "saturated fat"
    case cholesterol
    case potassium
    case sodium
    case macronutrients

    var id: Self { self }
}
