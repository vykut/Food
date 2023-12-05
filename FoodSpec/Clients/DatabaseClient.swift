//
//  DatabaseClient.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 03/12/2023.
//

import Foundation
import SwiftData
import ComposableArchitecture

@DependencyClient
struct DatabaseClient {
    var getRecentFoods: (_ sortedBy: Food.SortingStrategy, _ order: SortOrder) async throws -> [Food]
    var insert: (_ food: Food) async throws -> Void
    var delete: (_ food: Food) async throws -> Void
    var save: () async throws -> Void
}

extension DatabaseClient: DependencyKey {
    static var liveValue: DatabaseClient = {
        let container: ModelContainer = {
            let schema = Schema([
                Food.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                return container
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
        return .init(
            getRecentFoods: { sortedBy, order in
                let sortDescriptor: SortDescriptor<Food> = switch sortedBy {
                case .name: SortDescriptor(\.name, order: order)
                case .energy: SortDescriptor(\.energy.value, order: order)
                case .protein: SortDescriptor(\.protein.value, order: order)
                case .carbohydrates: SortDescriptor(\.carbohydrates.value, order: order)
                case .fat: SortDescriptor(\.fatTotal.value, order: order)
                }

                let foods = try await MainActor.run {
                    try container.mainContext.fetch(.init(sortBy: [sortDescriptor]))
                }

                return foods
            },
            insert: { food in
                try await MainActor.run {
                    container.mainContext.insert(food)
                    try container.mainContext.save()
                }
            },
            delete: { food in
                try await MainActor.run {
                    container.mainContext.delete(food)
                    try container.mainContext.save()
                }
            },
            save: {
                try await MainActor.run {
                    try container.mainContext.save()
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
