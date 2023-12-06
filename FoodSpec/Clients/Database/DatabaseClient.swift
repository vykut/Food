//
//  DatabaseClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 05/12/2023.
//

import Foundation
import GRDB
import ComposableArchitecture

@DependencyClient
struct DatabaseClient {
    var getRecentFoods: (_ sortedBy: Food.SortingStrategy, _ order: SortOrder) async throws -> [Food]
    var insert: (_ food: Food) async throws -> Food
    var delete: (_ food: Food) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    static var liveValue: DatabaseClient = {
        let db = createAppDatabase()
        return .init(
            getRecentFoods: { sortedBy, order in
                let column = sortedBy.column
                return try await db.read {
                    try Food
                        .order(order == .forward ? column : column.desc)
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

    static let testValue: DatabaseClient = .init()
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
