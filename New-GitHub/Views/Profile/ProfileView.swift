//
//  ProfileView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-17.
//

import SwiftUI

struct ProfileView: View {    
    @State private var filterState: FilterState = .all
    @State private var repoCount = 0
    @State private var showRepositoryDetail = false
    @State private var viewModel: ViewModel
    
    private let apiService: ApiServing
    private let avatarLoader: AvatarLoader
    private let username: String
    
    init(apiService: ApiServing, avatarLoader: AvatarLoader, username: String) {
        self.apiService = apiService
        self.username = username
        self.avatarLoader = avatarLoader
        self._viewModel = State(wrappedValue: ViewModel(apiService: apiService,
                                                        avatarLoader: avatarLoader,
                                                        username: username)
        )
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                skeletonLoadingListView
            case .loaded(let repos):
                VStack {
                    FilterBarView(filterState: $filterState)
                    
                    reposList(repos)
                }
            case .error(let error):
                ContentUnavailableView("Failed to load repositories",
                                       systemImage: "exclamationmark.bubble.fill",
                                       description: Text("Couldn't load repositories: \(error)")
                )
            }
        }
        .fullScreenCover(isPresented: $showRepositoryDetail) {
            Text("This is repository detail")
            
            Button("Dismiss") {
                showRepositoryDetail.toggle()
            }
        }
        .navigationTitle("\(username) - \(Int(repoCount)) related repos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProfileView {
    var skeletonLoadingListView: some View {
        List {
            ForEach(0...10, id: \.self) { _ in
                RepositoryCardSkeletonView()
            }
        }
        .listStyle(.inset)
        .shimmering()
    }
    
    func reposList(_ repos: [Repository]) -> some View {
        List(repos, id: \.self) { repo in
            Button(action: { showRepositoryDetail.toggle() }, label: {
                let ownerImage = repoOwnerImage(repo.owner.username)
                RepositoryCardView(repository: repo, image: ownerImage)
            })
            .buttonStyle(.plain)
            
        }
        .listStyle(.inset)
        .onAppear {
            repoCount = repos.count
        }
    }
    
    func repoOwnerImage(_ username: String) -> UIImage? {
        avatarLoader.images[username]
    }
}

#Preview {
    let cacheManager = MockCacheManager()
    let apiService = MockApiService(cacheManager: cacheManager)
    let fakeUser = User(id: 1, username: "davidmansourian", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User")
    @State var avatarLoader = AvatarLoader(apiService: apiService)
    return NavigationStack{ProfileView(apiService: apiService, avatarLoader: avatarLoader, username: fakeUser.username)}
}
