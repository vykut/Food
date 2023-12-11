import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
struct ApiKeysClient {
    var getApiKeys: () async throws -> ApiKeys
}

extension ApiKeysClient: DependencyKey {
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

    static let testValue: ApiKeysClient = .init()
}

extension DependencyValues {
    var apiKeysClient: ApiKeysClient {
        get { self[ApiKeysClient.self] }
        set { self[ApiKeysClient.self] = newValue }
    }
}

struct ApiKeys: Codable, Hashable {
    let ninja: String
}
