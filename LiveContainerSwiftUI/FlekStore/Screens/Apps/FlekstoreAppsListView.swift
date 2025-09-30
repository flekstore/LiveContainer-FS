//
//  FlekstoreAppsListView.swift
//  LiveContainer
//
//  Created by Alexander Grigoryev on 30.09.2025.
//

import SwiftUI

// MARK: - View
struct FlekstoreAppsListView: View {
    @StateObject private var viewModel = FlekstoreAppsListViewModel()
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            VStack {
                // Search field
                TextField("Search apps", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading apps…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        VStack {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                            Button("Retry") {
                                Task { await viewModel.fetchApps() }
                            }
                        }
                    } else {
                        List(viewModel.apps) { app in
                            AppRow(app: app, selectedTab: $selectedTab)
                                .buttonStyle(BorderlessButtonStyle())
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Updates")
        }
        .task {
            await viewModel.fetchApps()
        }
    }
}


// MARK: - Row
struct AppRow: View {
    let app: FSAppModel
    @Binding var selectedTab: Int
    @EnvironmentObject private var flekstoreSharedModel: FlekstoreSharedModel
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: app.app_icon)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.app_name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("Version \(app.app_version)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(app.app_short_description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            VStack {
                Spacer()
                Button(action: {
                    selectedTab = 1
                    flekstoreSharedModel.appInstallURL = app.install_url
                    print("new set url: \(app.install_url)")
                }) {
                    Text("GET")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 6)
    }
}


