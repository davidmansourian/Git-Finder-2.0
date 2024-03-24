//
//  SearchResultsView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import SwiftData
import SwiftUI

struct SearchResultsView: View {
    let apiService: ApiServing
    let avatarLoader: AvatarLoader
    let searchHistoryManager: SearchHistoryManager
    let users: [User]
    
    @State private var tappedUser: User?
    
    var body: some View {
        if !users.isEmpty {
            List(users, id: \.username) { user in
                NavigationLink(value: user) {
                    SearchResultItemView(username: user.username,
                                         userType: user.type,
                                         image: avatarLoader.images[user.username]
                    )
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationDestination(for: User.self) { user in
                let _ = searchHistoryManager.addSearchHistoryInstance(
                    user.username,
                    avatarData: avatarLoader.images[user.username]?.jpegData(
                        compressionQuality: 0.9
                    )
                )
                
                ProfileView(apiService: apiService, avatarLoader: avatarLoader, username: user.username)
            }
        } else {
            ContentUnavailableView("Couldn't find user", systemImage: "exclamationmark.magnifyingglass", description: Text("Try refining your search"))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SearchHistory.self, configurations: config)
    
    let cacheManager = MockCacheManager()
    let apiService = MockApiService(cacheManager: cacheManager)
    
    let user = User(id: 1, username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User")
    
    @State var avatarLoader = AvatarLoader(apiService: apiService)
    @State var searchHistoryManager = SearchHistoryManager(modelContext: container.mainContext)
    
    return SearchResultsView(apiService: apiService, avatarLoader: avatarLoader, searchHistoryManager: searchHistoryManager, users: [user])
}
