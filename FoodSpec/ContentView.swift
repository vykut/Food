//
//  ContentView.swift
//  FoodSpec
//
//  Created by Victor Socaciu on 29/11/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.foodClient) private var foodClient
    @Query private var recentFoods: [Food]
    @State private var searchQuery = ""
    @State private var isSearchFocused = false
    @State private var isSearching = false
    @State private var searchResults: [Food] = []
    @State private var searchTask: Task<Void, Error>?

    private var shouldShowRecentSearches: Bool {
        searchQuery.isEmpty && !recentFoods.isEmpty
    }

    private var shouldShowPrompt: Bool {
        searchQuery.isEmpty && recentFoods.isEmpty
    }

    private var shouldShowSpinner: Bool {
        isSearching
    }

    private var hasSearchResults: Bool {
        !searchResults.isEmpty
    }

    var body: some View {
        NavigationSplitView {
            List {
                if shouldShowRecentSearches {
                    recentSearches
                }
                if shouldShowPrompt {
                    ContentUnavailableView("Search for food", systemImage: "magnifyingglass")
                }
                // search results list
            }
            .searchable(text: $searchQuery, isPresented: $isSearchFocused)
            .overlay {
                if isSearching {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .navigationTitle("Search")
        } detail: {
            Text("Select an item")
        }
        .onChange(of: searchQuery) { old, new in
            searchTask?.cancel()
            searchTask = Task {
                try await Task.sleep(for: .milliseconds(300))
                isSearching = true
                defer { isSearching = false }
                do {
                    let items = try await foodClient.getFoods(query: searchQuery)
                } catch {
                    dump(error)
                }
                // make network request
                // update results
            }
        }
        .onAppear {
            if recentFoods.isEmpty && searchQuery.isEmpty {
                isSearchFocused = true
            }
        }
    }

    private var recentSearches: some View {
        Section {
            ForEach(recentFoods) { item in
                
            }
            .onDelete(perform: deleteItems)
        } header: {
            Text("Recent Searches")
        }
        .headerProminence(.increased)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recentFoods[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Food.self, inMemory: true)
}
