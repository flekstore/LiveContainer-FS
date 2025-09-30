//
//  FlekstoreAppsListViewModel.swift
//  LiveContainer
//
//  Created by Alexander Grigoryev on 30.09.2025.
//

import SwiftUI

@MainActor
class FlekstoreAppsListViewModel: ObservableObject {
    @Published var apps: [FSAppModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchQuery: String = ""
    
    private let urlString = "https://nestapitest.flekstore.com/app/with-link?page=0&search=false&filter=updates"
    
    func fetchApps() async {
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([FSAppModel].self, from: data)
            apps = decoded
        } catch {
            errorMessage = "Failed to load apps: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    var filteredApps: [FSAppModel] {
        if searchQuery.isEmpty {
            return apps
        }
        return apps.filter { app in
            app.app_name.localizedCaseInsensitiveContains(searchQuery) ||
            app.app_short_description.localizedCaseInsensitiveContains(searchQuery)
        }
    }
}
