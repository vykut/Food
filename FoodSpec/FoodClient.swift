//
//  FoodClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import Foundation

struct FoodClient {
    func getFoods(query: String) async throws -> [FoodApiModel] {
        guard var url = URL(string: "https://api.api-ninjas.com/v1/nutrition") else { return [] }
        url.append(
            queryItems: [
                .init(name: "query", value: query)
            ]
        )
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Z04HpCDGo4d9SuK4tdLbPw==PfKrz60ZTOx5MNLi", forHTTPHeaderField: "X-Api-Key")
        let (data, _) = try await URLSession.shared.data(for: request)
        let items = try JSONDecoder().decode([FoodApiModel].self, from: data)
        return items
    }
}

struct FoodApiModel: Hashable, Codable {
    let name: String
    let calories: Double
    let servingSizeG: Double
    let fatTotalG: Double
    let fatSaturatedG: Double
    let proteinG: Double
    let sodiumMg: Double
    let potassiumMg: Double
    let cholesterolMg: Double
    let carbohydratesTotalG: Double
    let fiberG: Double
    let sugarG: Double

    enum CodingKeys: String, CodingKey {
        case name
        case calories = "calories"
        case servingSizeG = "serving_size_g"
        case fatTotalG = "fat_total_g"
        case fatSaturatedG = "fat_saturated_g"
        case proteinG = "protein_g"
        case sodiumMg = "sodium_mg"
        case potassiumMg = "potassium_mg"
        case cholesterolMg = "cholesterol_mg"
        case carbohydratesTotalG = "carbohydrates_total_g"
        case fiberG = "fiber_g"
        case sugarG = "sugar_g"
    }
}
