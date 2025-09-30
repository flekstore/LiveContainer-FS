//
//  FlekstoreAppsListViewModel.swift
//  LiveContainer
//
//  Created by Alexander Grigoryev on 30.09.2025.
//

import SwiftUI

// MARK: - ViewModel
@MainActor
class FlekstoreAppsListViewModel: ObservableObject {
    @Published var apps: [FSAppModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchQuery: String = "" {
        didSet {
            Task {
                await fetchApps()
            }
        }
    }
    
    private let baseURLString = "https://nestapitest.flekstore.com/app/with-link?page=0&filter=updates"
    
    func fetchApps() async {
        // Build URL with search query
        let searchPart = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlStr = "\(baseURLString)&search=\(searchPart)"
        
        guard let url = URL(string: urlStr) else {
            errorMessage = "Invalid URL"
            return
        }
        
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
}
