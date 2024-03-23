//
//  ContentView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-07.
//

import SwiftData
import SwiftUI

struct SearchView: View {
    private let apiService: ApiServing
    private let avatarLoader: AvatarLoader
    
    @State private var path = NavigationPath()
    @State private var viewModel: ViewModel
    @State private var searchTerm = ""
    
    init(apiService: ApiServing, avatarLoader: AvatarLoader) {
        self.apiService = apiService
        self.avatarLoader = avatarLoader
        self._viewModel = State(wrappedValue: ViewModel(apiService: apiService, avatarLoader: avatarLoader))
        
        print("did init view")
    }

    var body: some View {
        NavigationStack(path: $path) {
            switch viewModel.state {
            case .idle:
                /// Search history
                usersList([])
            case .loading:
                loadingList
            case .loaded(let users):
                if !users.isEmpty {
                    usersList(users)
                } else {
                    Text("No users found")
                        .font(.largeTitle)
                        .fontWeight(.light)
                }
            case .error(let error):
                errorView(error)
            }
        }
        .searchable(text: $searchTerm)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
        .onChange(of: searchTerm) {
            viewModel.cancelSearchTask()
            callSearch()
        }
    }
}

extension SearchView {
    private func callSearch() {
        Task {
            await viewModel.handleSearch(for: searchTerm)
        }
    }
    
    private func usersList(_ users: [User]) -> some View {
        List(users, id: \.username) { user in
            NavigationLink(value: user) {
                ProfileResultItemView(username: user.username,
                                      userType: user.type,
                                      image: avatarLoader.images[user.username]
                )
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationDestination(for: User.self) { user in
            ProfileView(apiService: apiService, avatarLoader: avatarLoader, username: user.username)
        }
    }
    
    private var loadingList: some View {
        List(1...20, id: \.self) { _ in
            ProfileResultItemSkeletonView()
                .listRowSeparator(.hidden)
        }
        .shimmering()
        .listStyle(.plain)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Text(error)
                .fontWeight(.light)
            
            Button(action: {callSearch()}) {
                Image(systemName: "arrow.clockwise")
                    .font(.largeTitle)
                    .fontWeight(.light)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}


#Preview {
    let cacheManager = MockCacheManager()
    let apiService = MockApiService(cacheManager: cacheManager)
    @State var avatarLoader = AvatarLoader(apiService: apiService)
    return SearchView(apiService: apiService, avatarLoader: avatarLoader)
}
//
