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
        
        private var username: String
        private var repoResultsPageNumber = 1
        private var loadingError: String?
        
        private(set) var imageDatas = [String: Data]()
        private(set) var viewState: ViewState = .loading
        
        init(apiService: ApiServing, username: String) {
            self.apiService = apiService
            self.username = username
            
            handleRepoLoading()
        }

        // Regarding the page number, I need to check whether the fetched repos is < 30. If the repos are < 30, then I am on the last page, which means I shouldn't make any more api calls if I reach the end of the list
        // I can control this either through a boolean or an enum, then I can have a gurd statement within the function that handles the loading
        // I should also cache repo results. I can cache 30 items at a time, and store the key as username_page_1 or something similar. In the api call, I check whether the page number for the username's repo
        // is already cached
        
        // I should also create thumbnails for the photos that I am showing since they are so small
        private func handleRepoLoading() {
            Task { [weak self] in
                guard let self = self else { return }
                self.loadingError = nil
                let repos = await loadRepos()
                await loadImageDatas(for: repos)
                await updateUserState(repos)
            }
        }
        
        private func loadRepos() async -> [Repository]? {
            do {
                return try await apiService.fetchRepositories(for: username, pageNumber: repoResultsPageNumber)
            } catch {
                self.loadingError = (error as? CustomApiError)?.customDescription ?? error.localizedDescription
                return nil
            }
        }
        
        private func loadImageDatas(for repositories: [Repository]?) async {
            guard let repos = repositories else { return }
            await withTaskGroup(of: (String, Data).self) { [weak self] taskGroup in
                guard let self = self else { return }
                for repo in repos {
                    let imageUrl = repo.owner.avatarUrl
                    await storeImagesIfNecessary(for: repo.owner.username, with: imageUrl)
                }
            }
        }
        
        private func storeImagesIfNecessary(for username: String, with imageUrl: String) async {
            if !self.imageDatas.keys.contains(username) {
                if let imageData = try? await self.apiService.fetchImageData(for: imageUrl) {
                    self.imageDatas[username] = imageData
                }
            } else {
                // print("imageDatas already contains key-value pair of \(username). Skipping operation.")
            }
        }
        
        private func storeImageDataIfNecessary(_ username: String, imageData: Data) {
            if !self.imageDatas.keys.contains(username) {
                self.imageDatas[username] = imageData
            }
        }
        
        @MainActor
        private func updateUserState(_ repositories: [Repository]?) async {
            if let repos = repositories {
                self.viewState = .loaded(repos)
            } else if let error = loadingError {
                self.viewState = .error(error)
            }
        }
    }
}

extension ProfileView.ViewModel {
    enum ViewState: Equatable {
        case loading
        case loaded([Repository])
        case error(String)
    }
}
