//
//  FlekstoreAppsListViewModel.swift
//  LiveContainer
//
//  Created by Alexander Grigoryev on 30.09.2025.
//

// FlekstoreAppsListViewModel.swift
import SwiftUI

@MainActor
class FlekstoreAppsListViewModel: ObservableObject {
    @Published var apps: [FSAppModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @AppStorage("isAdult") private var isAdult: Bool = false

    @Published var searchQuery: String = ""
     
    @Published var allCategories: [FSCategory] = [
        .init(id: "32", name: " Arcade"),
        .init(id: "15", name: "Social media"),
        .init(id: "31", name: "Games"),
        .init(id: "1", name: "Emulators"),
        .init(id: "7", name: "Music"),
        .init(id: "30", name: "Photo & Video"),
        .init(id: "3", name: "Adult"),
        .init(id: "16", name: "Movies"),
        .init(id: "23", name: "Tools"),
        .init(id: "42", name: "AI tools"),
        .init(id: "24", name: "Jailbreak"),
        .init(id: "45", name: "Sport")
    ]
    
    var categories: [FSCategory] {
            // Filter out "Adult" if user is not adult
            allCategories.filter { category in
                if category.id == "3" {
                    return isAdult
                }
                return true
            }
        }
    // Selected category — `nil` meaning "All / updates"
    @Published var selectedCategoryID: String? = nil
    
    // Pagination
    private var currentPage = 0
    private var canLoadMore = true
    
    // Debounce task for search
    private var searchDebounceTask: Task<Void, Never>?
    
    // Base endpoint (we construct query items with URLComponents)
    private let baseEndpoint = "https://nestapitest.flekstore.com/app/with-link"
    
    // Public: call this when user types in the TextField (from the View `.onChange`)
    func debounceSearch(_ newQuery: String) {
        // Cancel any pending debounce
        searchDebounceTask?.cancel()
        
        // Schedule new debounce
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000) // 350 ms
            guard !Task.isCancelled else { return }
            await self?.resetAndFetchApps()
        }
    }
    
    // Public: call when category button pressed
    func selectCategory(_ id: String?) {
        // If selecting same category, do nothing (optional)
        if selectedCategoryID == id { return }
        
        // Cancel pending debounce (so a pending search won't race)
        searchDebounceTask?.cancel()
        
        selectedCategoryID = id
        Task { await resetAndFetchApps() }
    }
    
    // Reset paging and fetch first page
    func resetAndFetchApps() async {
        currentPage = 0
        canLoadMore = true
        apps = []
        await fetchApps()
    }
    
    // Fetch next page
    func fetchApps() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        errorMessage = nil
        
        // Build URL with URLComponents
        var components = URLComponents(string: baseEndpoint)
        var queryItems: [URLQueryItem] = []
        
        // filter either numeric category id or "updates"
        let filterValue = selectedCategoryID ?? "updates"
        queryItems.append(URLQueryItem(name: "filter", value: filterValue))
        queryItems.append(URLQueryItem(name: "page", value: "\(currentPage)"))
        
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        queryItems.append(URLQueryItem(name: "search", value: trimmed.isEmpty ? "false" : trimmed))
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([FSAppModel].self, from: data)
            
            if decoded.isEmpty {
                // no more pages
                canLoadMore = false
            } else {
                apps.append(contentsOf: decoded)
                currentPage += 1
            }
        } catch {
            errorMessage = "Failed to load apps: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
