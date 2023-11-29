//
//  FoodSpecApp.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import SwiftUI
import SwiftData
import FoodClient

@main
struct FoodSpecApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Food.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

extension FoodClient: EnvironmentKey {
    public static let defaultValue: Self = .init()
}

extension EnvironmentValues {
    var foodClient: FoodClient {
        get {
            self[FoodClient.self]
        }
        set {
            self[FoodClient.self] = newValue
        }
    }
}
