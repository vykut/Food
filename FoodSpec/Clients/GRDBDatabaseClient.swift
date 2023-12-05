//
//  GRDBDatabaseClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 05/12/2023.
//

import Foundation
import GRDB
import ComposableArchitecture

@DependencyClient
struct GRDBDatabaseClient {
    var getRecentFoods: (_ sortedBy: Column, _ order: SortOrder) async throws -> [GRDBFood]
    var insert: (_ food: GRDBFood) async throws -> GRDBFood
    var delete: (_ food: GRDBFood) async throws -> Void
}

extension GRDBDatabaseClient: DependencyKey {
    static var liveValue: GRDBDatabaseClient = {
        let db = AppDatabase.shared.dbWriter
        return .init(
            getRecentFoods: { sortedBy, order in
                return try await db.read {
                    try GRDBFood
                        .order(order == .forward ? sortedBy : sortedBy.desc)
                        .fetchAll($0)
                }
            },
            insert: { food in
                try await db.write {
                    try food.inserted($0)
                }
            },
            delete: { food in
                try await db.write {
                    _ = try food.delete($0)
                }
            }
        )
    }()

    static let testValue: GRDBDatabaseClient = .init()
}

extension DependencyValues {
    var grdbDatabaseClient: GRDBDatabaseClient {
        get { self[GRDBDatabaseClient.self] }
        set { self[GRDBDatabaseClient.self] = newValue }
    }
}
