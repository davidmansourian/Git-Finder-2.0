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
    private let username: String
    
    init(apiService: ApiServing, username: String) {
        self.apiService = apiService
        self.username = username
        self._viewModel = State(wrappedValue: ViewModel(apiService: apiService,
                                                        username: username))
    }
    
    var body: some View {
        Group {
            switch viewModel.viewState {
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
                let ownerImageData = repoOwnerImageData(repo.owner.username)
                RepositoryCardView(repository: repo, imageData: ownerImageData)
            })
            .buttonStyle(.plain)
            
        }
        .listStyle(.inset)
        .onAppear {
            repoCount = repos.count
        }
    }
    
    func repoOwnerImageData(_ username: String) -> Data? {
        viewModel.imageDatas[username]
    }
}

#Preview {
    @State var apiService = MockApiService()
    let avatar = UIImage(named: "testAvataar")
    let avatarData = avatar?.jpegData(compressionQuality: 0.9)
    let fakeUser = User(id: 1, username: "davidmansourian", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User", avatarImageData: avatarData)
    return NavigationStack{ProfileView(apiService: apiService, username: fakeUser.username)}
}
