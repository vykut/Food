import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct FoodClient: Sendable {
    public var getFoods: (_ query: String) async throws -> [FoodApiModel]
}

extension FoodClient: DependencyKey {
    public static let liveValue: FoodClient = .init(
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
            do {
                let (data, _) = try await session.data(for: request)
                let items = try JSONDecoder().decode([FoodApiModel].self, from: data)
                let foodsWithValidServingSize = items.filter(hasValidServingSize)
                return foodsWithValidServingSize
            } catch {
                try Task.checkCancellation()
                throw error
            }
        }
    )

    public static let testValue: FoodClient = .init()
}

extension DependencyValues {
    public var foodClient: FoodClient {
        get { self[FoodClient.self] }
        set { self[FoodClient.self] = newValue }
    }
}

func hasValidServingSize(_ food: FoodApiModel) -> Bool {
    (99.5...100.5).contains(food.servingSizeG)
}

public struct FoodApiModel: Hashable, Codable {
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

    init(
        name: String,
        calories: Double,
        servingSizeG: Double,
        fatTotalG: Double,
        fatSaturatedG: Double,
        proteinG: Double,
        sodiumMg: Double,
        potassiumMg: Double,
        cholesterolMg: Double,
        carbohydratesTotalG: Double,
        fiberG: Double,
        sugarG: Double
    ) {
        self.name = name
        self.calories = calories
        self.servingSizeG = servingSizeG
        self.fatTotalG = fatTotalG
        self.fatSaturatedG = fatSaturatedG
        self.proteinG = proteinG
        self.sodiumMg = sodiumMg
        self.potassiumMg = potassiumMg
        self.cholesterolMg = cholesterolMg
        self.carbohydratesTotalG = carbohydratesTotalG
        self.fiberG = fiberG
        self.sugarG = sugarG
    }

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

public extension FoodApiModel {
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
            carbohydratesTotalG: 8.7,
            fiberG: 2.5,
            sugarG: 3.2
        )
    }
}
