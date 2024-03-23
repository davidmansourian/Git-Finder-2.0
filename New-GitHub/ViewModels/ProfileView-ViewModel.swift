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
        
        private func handleRepoLoading() {
            Task { [weak self] in
                guard let self = self else { return }
                self.loadingError = nil
                let repos = await loadRepos()
                await avatarLoader.loadAvatarImages(for: repos, requestedHeight: repoOwnerAvatarHeight)
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
