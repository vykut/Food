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
    @Query(sort: \Food.openDate, order: .reverse) private var recentFoods: [Food]
    @State private var navigationStack: [Food] = []
    @State private var searchQuery = ""
    @State private var isSearchFocused = false
    @State private var isSearching = false
    @State private var searchResults: [FoodApiModel] = []
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

    private var shouldShowSearchResults: Bool {
        isSearchFocused && !searchResults.isEmpty
    }

    var body: some View {
        let _ = Self._printChanges()
        NavigationStack(path: $navigationStack) {
            List {
                if shouldShowRecentSearches {
                    recentSearches
                }
                if shouldShowPrompt {
                    ContentUnavailableView("Search for food", systemImage: "magnifyingglass")
                }
                if shouldShowSearchResults {
                    searchResultsList
                }
            }
            .listStyle(.sidebar)
            .searchable(text: $searchQuery, isPresented: $isSearchFocused)
            .overlay {
                if isSearching {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .navigationTitle("Search")
            .navigationDestination(for: Food.self) { food in
                FoodDetail(food: food)
            }
        }
        .onChange(of: searchQuery) { old, new in
            searchTask?.cancel()
            if !new.isEmpty {
                searchTask = Task {
                    try await Task.sleep(for: .milliseconds(300))
                    isSearching = true
                    defer { isSearching = false }
                    do {
                        let items = try await foodClient.getFoods(query: searchQuery)
                        print(items)
                        searchResults = items
                    } catch {
                        // handle errors
                        dump(error)
                    }
                }
            } else {
                searchResults = []
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
                Button {
                    navigationStack.append(item)
                } label: {
                    Text(item.name.capitalized)
                }
            }
            .onDelete(perform: deleteItems)
        } header: {
            Text("Recent Searches")
        }
    }

    private var searchResultsList: some View {
        Section {
            ForEach(searchResults, id: \.self) { item in
                Button {
                    let food = Food(foodApiModel: item, date: .now)
                    modelContext.insert(food)
                    navigationStack.append(food)
                } label: {
                    Text(item.name.capitalized)
                }
            }
        } header: {
            Text("Results")
        }
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
