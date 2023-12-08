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
    var observeFoods: (_ sortedBy: Food.SortingStrategy, _ order: SortOrder) -> AsyncStream<[Food]> = { _, _ in .finished }
    var getRecentFoods: (_ sortedBy: Food.SortingStrategy, _ order: SortOrder) async throws -> [Food]
    var getFood: (_ name: String) async throws -> Food?
    var insert: (_ food: Food) async throws -> Food
    var delete: (_ food: Food) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    static var liveValue: DatabaseClient = {
        let db = createAppDatabase()
        @Sendable func fetchFoods(db: Database, sortedBy column: Column, order: SortOrder) throws -> [Food] {
            try Food
                .order(order == .forward ? column : column.desc)
                .fetchAll(db)
        }
        return .init(
            observeFoods: { sortedBy, order in
                let column = sortedBy.column
                let observation = ValueObservation.tracking {
                    try fetchFoods(db: $0, sortedBy: sortedBy.column, order: order)
                }
                return AsyncStream(observation.values(in: db))
            },
            getRecentFoods: { sortedBy, order in
                return try await db.read {
                    try fetchFoods(db: $0, sortedBy: sortedBy.column, order: order)
                }
            },
            getFood: { name in
                return try await db.read {
                    try Food
                        .filter(Column("name") == name)
                        .fetchOne($0)
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
