//
//  ProfileView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-17.
//

import SwiftUI

struct ProfileView: View {
    @State private var filterState: FilterState = .all
    @State private var sortState: SortState = .originalOrder
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
                    
                    if viewModel.scrollLoading {
                        ProgressView()
                    }
                    
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        toolbarSortMenuView
                    }
                }
                .onChange(of: filterState) {
                    Task { await viewModel.setUserResultsWithFilterAndSort(filterState, sortState) }
                }
                .onChange(of: sortState) {
                    Task { await viewModel.setUserResultsWithFilterAndSort(filterState, sortState)}
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
        .navigationTitle("\(username) - \(Int(viewModel.repoCount)) related repos")
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
                RepositoryCardView(repository: repo,
                                   image: repoOwnerImage(repo.owner.username)
                )
            })
            .buttonStyle(.plain)
            .onAppear {
                if repo == repos.last &&
                    (filterState == .all || filterState == .owner)
                {
                    viewModel.loadingTask?.cancel()
                    viewModel.scrollRepositories(consider: filterState, and: sortState)
                }
            }
        }
        .listStyle(.inset)
    }
    
    func repoOwnerImage(_ username: String) -> UIImage? {
        viewModel.avatarImages[username]
    }
    
    var toolbarSortMenuView: some View {
        Menu {
            Menu {
                Button {
                    handleSortStateSelection(.watchersAscending)
                } label: {
                    customMenuLabel("Ascending", isSelected: sortState == .watchersAscending)
                }
                
                Button {
                    handleSortStateSelection(.watchersDescending)
                } label: {
                    customMenuLabel("Descending", isSelected: sortState == .watchersDescending)
                }
                
            } label: {
                Label("Watchers", systemImage: "eye")
            }
            
            Menu {
                Button
                {
                    handleSortStateSelection(.latest)
                } label: {
                    customMenuLabel("Latest", isSelected: sortState == .latest)
                }
                
                Button
                {
                    handleSortStateSelection(.oldest)
                } label: {
                    customMenuLabel("Oldest", isSelected: sortState == .oldest)
                }
                
            } label: {
                Label("Date", systemImage: "calendar")
            }
            
        } label: {
            Label("Sort by", systemImage: "arrow.up.arrow.down")
        }
    }
    
    @ViewBuilder
    func customMenuLabel(_ title: String, isSelected: Bool) -> some View {
        if isSelected {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }
    
    func handleSortStateSelection(_ sortState: SortState) {
        if sortState == self.sortState {
            self.sortState = .originalOrder
        } else {
            self.sortState = sortState
        }
    }
}

extension ProfileView {
    enum FilterState: Int, CaseIterable {
        case all
        case owner
        case contributor
        
        var title: String {
            switch self {
            case .all: return "All repos"
            case .owner: return "Owned"
            case .contributor: return "Contributor"
            }
        }
    }
    
    enum SortState {
        case watchersAscending, watchersDescending, latest, oldest, originalOrder
    }
}

#Preview {
    let cacheManager = MockCacheManager()
    let apiService = MockApiService(cacheManager: cacheManager)
    let fakeUser = User(id: 1, username: "davidmansourian", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User")
    @State var avatarLoader = AvatarLoader(apiService: apiService)
    return NavigationStack{ProfileView(apiService: apiService, avatarLoader: avatarLoader, username: fakeUser.username)}
}
