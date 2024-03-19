//
//  ProfileView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-17.
//

import SwiftUI

struct ProfileView: View {    
    @State private var filterState: FilterState = .all
    @State private var showRepositoryDetail = false
    @State private var viewModel: ViewModel
    
    private let apiService: ApiServing
    private let user: User
    
    init(apiService: ApiServing, user: User) {
        self.apiService = apiService
        self.user = user
        self._viewModel = State(wrappedValue: ViewModel(apiService: apiService,
                                                        username: user.username))
    }
    
    var body: some View {
        VStack {
            FilterBarView(filterState: $filterState)
            
            if let repositories = viewModel.repositories {
                List(repositories, id: \.self) { repo in
                    Button(action: { showRepositoryDetail.toggle() }, label: {
                        RepositoryCardView(repository: repo)
                    })
                    .buttonStyle(.plain)
                    
                }
                .listStyle(.inset)
            } else {
                skeletonLoadingListView
            }
        }
        .fullScreenCover(isPresented: $showRepositoryDetail) {
            Text("This is repository detail")
            
            Button("Dismiss") {
                showRepositoryDetail.toggle()
            }
        }
        .navigationTitle("\(user.username) - \(Int(publicRepos)) related repos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProfileView {
    var publicRepos: Int {
        guard let repoCount = viewModel.repositories?.count else { return 0 }
        return repoCount
    }
    
    var skeletonLoadingListView: some View {
        List {
            ForEach(0...10, id: \.self) { _ in
                RepositoryCardSkeletonView()
            }
        }
        .listStyle(.inset)
        .shimmering()
    }
}

#Preview {
    @State var apiService = MockApiService()
    let avatar = UIImage(named: "testAvataar")
    let avatarData = avatar?.jpegData(compressionQuality: 0.9)
    let fakeUser = User(id: 1, username: "davidmansourian", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User", avatarImageData: avatarData)
    return NavigationStack{ProfileView(apiService: apiService, user: fakeUser)}
}
