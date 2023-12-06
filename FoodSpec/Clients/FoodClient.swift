//
//  FoodClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct FoodClient {
    var getFoods: (_ query: String) async throws -> [FoodApiModel]
}

extension FoodClient: DependencyKey {
    static let liveValue: FoodClient = .init(
        getFoods: { query in
            @Dependency(\.apiKeysClient) var apiKeysClient
            @Dependency(\.urlSession) var session

            let apiKeys = try await apiKeysClient.getApiKeys()
            guard var url = URL(string: "https://api.api-ninjas.com/v1/nutrition") else { return [] }
            url.append(
                queryItems: [
                    .init(name: "query", value: query)
                ]
            )
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(apiKeys.ninja, forHTTPHeaderField: "X-Api-Key")
            let (data, _) = try await session.data(for: request)
            let items = try JSONDecoder().decode([FoodApiModel].self, from: data)
            return items
        }
    )

    static let testValue: FoodClient = .init()
}

extension DependencyValues {
    var foodClient: FoodClient {
        get { self[FoodClient.self] }
        set { self[FoodClient.self] = newValue }
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

extension FoodApiModel {
    static var preview: Self {
        .init(
            name: "eggplant",
            calories: 34.7,
            servingSizeG: 100,
            fatTotalG: 0.2,
            fatSaturatedG: 0.0,
            proteinG: 0.8,
            sodiumMg: 0.0,
            potassiumMg: 15.0,
            cholesterolMg: 0.0,
            carbohydratesTotalG: 0.7,
            fiberG: 2.5,
            sugarG: 3.2
        )
    }
}
