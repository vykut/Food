import Foundation
import Shared
import Dependencies
import DependenciesMacros
@_exported import GRDB

@DependencyClient
public struct DatabaseClient {
    public var observeFoods: (_ sortedBy: Column, _ order: SortOrder) -> AsyncStream<[Food]> = { _, _ in .finished }
    public var getRecentFoods: (_ sortedBy: Column, _ order: SortOrder) async throws -> [Food]
    public var getFood: (_ name: String) async throws -> Food?
    public var insert: (_ food: Food) async throws -> Food
    public var delete: (_ food: Food) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    public static var liveValue: DatabaseClient = {
        let db = createAppDatabase()
        @Sendable func fetchFoods(db: Database, sortedBy column: Column, order: SortOrder) throws -> [Food] {
            try Food
                .order(order == .forward ? column : column.desc)
                .fetchAll(db)
        }
        return .init(
            observeFoods: { column, order in
                let observation = ValueObservation.tracking {
                    try fetchFoods(db: $0, sortedBy: column, order: order)
                }
                return AsyncStream(observation.values(in: db))
            },
            getRecentFoods: { column, order in
                return try await db.read {
                    try fetchFoods(db: $0, sortedBy: column, order: order)
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

    public static let testValue: DatabaseClient = .init()
}

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
