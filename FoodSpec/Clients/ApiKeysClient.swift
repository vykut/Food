//
//  ApiKeysClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 02/12/2023.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct ApiKeysClient {
    var getApiKeys: () async throws -> ApiKeys
}

private enum ApiKeysClientKey: DependencyKey {
    static let liveValue: ApiKeysClient = .init(
        getApiKeys: {
            let request = NSBundleResourceRequest(tags: ["APIKeys"])
            try await request.beginAccessingResources()
            let url = Bundle.main.url(forResource: "APIKeys", withExtension: "json")!
            let data = try Data(contentsOf: url)
            // TODO: Store in keychain and skip NSBundleResourceRequest on next launches
            let apiKeys = try JSONDecoder().decode(ApiKeys.self, from: data)
            request.endAccessingResources()
            return apiKeys
        }
    )
}

extension DependencyValues {
    var apiKeysClient: ApiKeysClient {
        get { self[ApiKeysClientKey.self] }
        set { self[ApiKeysClientKey.self] = newValue }
    }
}

struct ApiKeys: Codable, Hashable {
    let ninja: String
}