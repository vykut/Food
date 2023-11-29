//
//  FoodClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import Foundation
import OpenAPIURLSession
import OpenAPIRuntime
import HTTPTypes

struct ApiKeyMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        var rq = request
//        rq.path?.append("&api_key=Y7l7jgqFbdWcZV0MoUvicSBpNeLshxGpIB908WZv")

        return try await next(rq, body, baseURL)
    }
}

public struct FoodClient {
    private let client = Client(
        serverURL: try! Servers.server1(),
        transport: URLSessionTransport(),
        middlewares: [
            ApiKeyMiddleware()
        ]
    )

    public init() { }

    public func getFoods(query: String) async throws -> [Int] {
        let response = try await client.get_sol_api_sol_food_hyphen_database_sol_v2_sol_parser(
            query: .init(
                app_id: "22c40eea",
                app_key: "0ee43ebf69435402b531a1217a6fa22a",
                ingr: query
            )
        )

        switch response {
            case .ok(let ok):
                dump(ok)
            case .notFound(let notFound):
                dump(notFound)
            case .undocumented(let statusCode, let payload):
                print("Error: \(statusCode)")
                dump(payload)
        }

        return []
    }
}
