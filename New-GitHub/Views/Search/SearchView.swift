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
    @State private var searchHistoryManager: SearchHistoryManager
    @State private var searchTerm = ""
    
    init(
        apiService: ApiServing,
        avatarLoader: AvatarLoader,
        modelContext: ModelContext
    ) {
        self.apiService = apiService
        self.avatarLoader = avatarLoader
        self._viewModel = State(wrappedValue: ViewModel(apiService: apiService, avatarLoader: avatarLoader))
        self._searchHistoryManager = State(wrappedValue: SearchHistoryManager(modelContext: modelContext))
        print("did init view")
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            switch viewModel.state {
            case .idle:
                SearchHistoryView(
                    apiService: apiService,
                    avatarLoader: avatarLoader,
                    searchHistoryManager: searchHistoryManager
                )
            case .loading:
                loadingList
            case .loaded(let users):
                SearchResultsView(
                    apiService: apiService,
                    avatarLoader: avatarLoader,
                    searchHistoryManager: searchHistoryManager,
                    users: users
                )
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
                SearchResultItemView(username: user.username,
                                     userType: user.type,
                                     image: avatarLoader.images[user.username]
                )
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationDestination(for: User.self) { user in
            let _ = Task {
                await searchHistoryManager.addSearchHistoryInstance(
                    user.username,
                    avatarData: avatarLoader.images[user.username]?.jpegData(
                        compressionQuality: 0.9
                    )
                )
            }
            ProfileView(apiService: apiService, avatarLoader: avatarLoader, username: user.username)
        }
    }
    
    private var loadingList: some View {
        List(1...20, id: \.self) { _ in
            SearchResultItemSkeletonView()
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SearchHistory.self, configurations: config)
    
    let cacheManager = MockCacheManager()
    let apiService = MockApiService(cacheManager: cacheManager)
    
    @State var avatarLoader = AvatarLoader(apiService: apiService)
    
    return SearchView(apiService: apiService, avatarLoader: avatarLoader, modelContext: container.mainContext)
}
//
