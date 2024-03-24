//
//  SearchHistoryView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import SwiftData
import SwiftUI

struct SearchHistoryView: View {
    let apiService: ApiServing
    let avatarLoader: AvatarLoader
    let searchHistoryManager: SearchHistoryManager
    
    @State private var tappedUsername: String?
    
    var body: some View {
        Group {
            if !searchHistoryManager.searchHistory.isEmpty {
                VStack(alignment: .leading) {
                    Text("Recent")
                        .padding(.horizontal)
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                    List(searchHistoryManager.searchHistory) { searchHistory in
                        Button {
                            self.tappedUsername = searchHistory.username
                            searchHistoryManager.addSearchHistoryInstance(
                                searchHistory.username,
                                avatarData: searchHistory.avatarData
                            )
                        } label: {
                            SearchHistoryItemView(
                                searchHistoryManager: searchHistoryManager,
                                historyInstance: searchHistory,
                                avatarData: searchHistory.avatarData
                            )
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .navigationDestination(item: $tappedUsername) { username in
                        ProfileView(
                            apiService: apiService,
                            avatarLoader: avatarLoader,
                            username: username
                        )
                    }
                }
            } else {
                ContentUnavailableView("Search for users", systemImage: "magnifyingglass", description: Text("Search for users in the searchbar above"))
            }
        }
        .navigationTitle("Git Finder 2.0")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SearchHistory.self, configurations: config)
    
    let user = User(id: 1, username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User")
    let testAvatar = UIImage(named: "testAvatar")
    let searchHistoryInstance = SearchHistory(username: user.username, lastVisited: .now, avatarData: testAvatar?.pngData() ?? Data())
    
    container.mainContext.insert(searchHistoryInstance)
    
    let cacheManager = MockCacheManager()
    let apiService = MockApiService(cacheManager: cacheManager)
    let avatarLoader = AvatarLoader(apiService: apiService)
    
    @State var searchHistoryManager = SearchHistoryManager(modelContext: container.mainContext)
    
    return SearchHistoryView(apiService: apiService, avatarLoader: avatarLoader, searchHistoryManager: searchHistoryManager)
}
