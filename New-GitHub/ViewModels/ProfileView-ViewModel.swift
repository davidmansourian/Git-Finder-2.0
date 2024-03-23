//
//  ProfileView-ViewModel.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-17.
//

import Foundation

extension ProfileView {
    @Observable
    public final class ViewModel {
        private let apiService: ApiServing
        private let avatarLoader: AvatarLoader
        
        private var loadingError: String?
        private var repoOwnerAvatarHeight: CGFloat = 18
        private var repoResultsPageNumber = 1
        private var username: String

        private(set) var state: State = .loading
        
        init(apiService: ApiServing, avatarLoader: AvatarLoader, username: String) {
            self.apiService = apiService
            self.avatarLoader = avatarLoader
            self.username = username
            
            handleRepoLoading()
        }

        // Regarding the page number, I need to check whether the fetched repos is < 30. If the repos are < 30, then I am on the last page, which means I shouldn't make any more api calls if I reach the end of the list
        // I can control this either through a boolean or an enum, then I can have a gurd statement within the function that handles the loading
        // I should also cache repo results. I can cache 30 items at a time, and store the key as username_page_1 or something similar. In the api call, I check whether the page number for the username's repo
        // is already cached
        
        // I should also create thumbnails for the photos that I am showing since they are so small
        
        // I should also consider separating image loading to its own manager that holds images similar to this. To manage memory, I can se the imageDatas to nil everytime a new action is performed
        private func handleRepoLoading() {
            Task { [weak self] in
                guard let self = self else { return }
                self.loadingError = nil
                let repos = await loadRepos()
                await avatarLoader.loadImageDatas(for: repos, requestedHeight: repoOwnerAvatarHeight)
                await updateUserState(repos)
            }
        }
        
        private func loadRepos() async -> [Repository]? {
            do {
                return try await apiService.fetchRepositories(for: username, pageNumber: repoResultsPageNumber)
            } catch {
                self.loadingError = error.localizedDescription
                return nil
            }
        }
        
//        private func loadImageDatas(for repositories: [Repository]?) async {
//            guard let repos = repositories else { return }
//            await withTaskGroup(of: (String, Data).self) { [weak self] taskGroup in
//                guard let self = self else { return }
//                for repo in repos {
//                    let imageUrl = repo.owner.avatarUrl
//                    await avatarLoader.storeImageDatasIfNecessary(
//                        for: repo.owner.username,
//                        with: imageUrl,
//                        currentView: .profile,
//                        requestedHeight: repoOwnerAvatarHeight
//                    )
//                }
//            }
//        }
        
        @MainActor
        private func updateUserState(_ repositories: [Repository]?) async {
            if let repos = repositories {
                self.state = .loaded(repos)
            } else if let error = loadingError {
                self.state = .error(error)
            }
        }
    }
}

extension ProfileView.ViewModel {
    enum State: Equatable {
        case loading
        case loaded([Repository])
        case error(String)
    }
}
