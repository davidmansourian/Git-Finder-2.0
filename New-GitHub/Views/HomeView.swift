//
//  ContentView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-07.
//

import SwiftUI

struct HomeView: View {
    @Environment(ApiService.self) private var apiService
    @State private var userResults: UserSearchResult?
    
    @State private var searchTerm = ""
    @State var searchTask: Task<UserSearchResult, Error>?
    
    // Need different view states:
    /// - When searchTerm is empty and user has stored search history = show history
    /// - When searchTerm is empty and user has no stored search history = show instruction
    /// - When searchTerm is not empty = show userResults
    var body: some View {
        NavigationStack {
            if let users = userResults?.users {
                List(users) { user in
                    ResultItemView(user: user)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $searchTerm)
        .onChange(of: searchTerm) {
            searchTask?.cancel()
            
            if !searchTerm.isEmpty {
                Task {
                    await handleSearch()
                }
            } else {
                userResults = nil
            }
        }
    }
}

extension HomeView {
    func handleSearch() async {
        let task = Task.detached(priority: .userInitiated) {
            try await Task.sleep(for: .seconds(0.5))
            
            do {
                return try await apiService.fetchUsernames(for: searchTerm)
            } catch {
                if let error = error as? CustomApiError {
                    print(error.customDescription)
                } else {
                    print(error.localizedDescription)
                }
                return UserSearchResult(resultsCount: 0, incompleteResults: true, users: [])
            }
            
        }
        
        searchTask = task
        
        userResults = try? await task.value
    }
}

#Preview {
    @State var apiService = ApiService()
    return HomeView()
        .environment(apiService)
}
