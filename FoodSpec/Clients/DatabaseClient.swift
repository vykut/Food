//
//  DatabaseClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 03/12/2023.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct DatabaseClient {
    var getRecentFoods: () async throws -> [Food]
    var insert: (_ food: Food) async -> Void
    var delete: (_ food: Food) async -> Void
    var save: () async throws -> Void
}

private enum DatabaseClientKey: DependencyKey {
    static var liveValue: DatabaseClient = .init(
        getRecentFoods: {
            let container = PersistenceController.sharedModelContainer

            let foods = try await MainActor.run {
                return try container.mainContext.fetch(.init(sortBy: [.init(\Food.openDate, order: .reverse)]))
            }

            return foods
        },
        insert: { food in
            let container = PersistenceController.sharedModelContainer
            await MainActor.run {
                container.mainContext.insert(food)
            }
        },
        delete: { food in
            let container = PersistenceController.sharedModelContainer
            await MainActor.run {
                container.mainContext.delete(food)
            }
        },
        save: {
            let container = PersistenceController.sharedModelContainer
            try await MainActor.run {
                try container.mainContext.save()
            }
        }
    )
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClientKey.self] }
        set { self[DatabaseClientKey.self] = newValue }
    }
}
