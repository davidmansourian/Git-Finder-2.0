//
//  RepositoryDetailView-ViewModel.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import Foundation
import SwiftUI

extension RepositoryDetailView {
    @Observable
    public final class ViewModel {
        private let apiService: ApiServing
        private let avatarLoader: AvatarLoader
        private let username: String
        private let repositoryName: String
        
        private var languageLoadingError: String?
        private var contributorsLoadingError: String?
        
        private(set) var contributors = [Contributor]()
        private(set) var contributorsAvatars = [String:UIImage]()
        private(set) var languageLoadingState: LanguageLoadingState = .loading
        private(set) var contributorLoadingState: ContributorLoadingState = .loading
        
        
        init(apiService: ApiServing, avatarLoader: AvatarLoader, username: String, repositoryName: String) {
            self.apiService = apiService
            self.avatarLoader = avatarLoader
            self.username = username
            self.repositoryName = repositoryName
            
            loadRepoDetails()
        }
        
        private func loadRepoDetails() {
            Task {
                let repoLanguages = await loadRepoLanguages()
                let contributors = await loadContributors()
                await updateUserState(repoLanguages, contributors)
            }
        }
        
        private func loadRepoLanguages() async -> [RepoLanguage]? {
            do {
                let languageResponse = try await apiService.fetchLanguages(repoName: repositoryName)
                let repoLanguages = try await languagesAndColors(languageResponse)
                return repoLanguages
            } catch {
                print("got error: \(error.localizedDescription)")
                languageLoadingError = error.localizedDescription
                return nil
            }
        }
        
        private func loadContributors() async -> [Contributor]? {
            do {
                self.contributors = try await apiService.fetchContributors(repoName: repositoryName)
                contributorsAvatars = try await avatarLoader.loadAvatarImages(for: contributors, requestedHeight: 30)
                return contributors
            } catch {
                contributorsLoadingError = error.localizedDescription
                return nil
            }
        }
        
        private func languagesAndColors(_ languageResponse: [String: Int]) async throws -> [RepoLanguage]? {
            guard !languageResponse.isEmpty else {
                languageLoadingError = "No languages available"
                return nil
            }
            
            var repoLanguages = [RepoLanguage]()
            
            let totalBytes = languageResponse.reduce(0) { $0 + $1.value }
            
            for (language, bytes) in languageResponse {
                let bytesPercentage = (Double(bytes) / Double(totalBytes)) * 100
                let hexColor = gitLanguageColors[language] ?? ""
                let color = Color.init(hex: hexColor) ?? .primary
                let languageInstance = RepoLanguage(language: language, percentage: bytesPercentage, color: color)
                repoLanguages.append(languageInstance)
            }
            
            repoLanguages.sort(by: {$0.percentage > $1.percentage})
            
            return repoLanguages
        }
        
        public func topContributorImages() -> [IndexedAvatar]? {
            var avatars = [IndexedAvatar]()
            
            for i in contributors.indices {
                guard avatars.count < 3 else { break }
                
                let contributor = contributors[i].username
                if let contributorAvatar = contributorsAvatars[contributor] {
                    let instance = IndexedAvatar(id: i, avatar: contributorAvatar)
                    avatars.append(instance)
                }
            }
            
            return avatars
        }
        
        // https://github.com/apple/app-store-server-library-java/blob/main/README.md
        // https://github.com/marksamman/atom-shell/blob/master/README.md
        public func readmeUrl(for repoName: String, defaultBranch: String) -> URL? {
            let urlString = "https://github.com/\(repoName)/blob/\(defaultBranch)/README.md"
            return URL(string: urlString)
        }
        
        @MainActor
        private func updateUserState(_ repoLanguages: [RepoLanguage]? = nil, _ contributors: [Contributor]? = nil) {
            if let languages = repoLanguages {
                languageLoadingState = .loaded(languages)
            }
            
            if let contributors = contributors {
                contributorLoadingState = .loaded(contributors)
            }
            
            if let contributorsError = contributorsLoadingError {
                contributorLoadingState = .error
            }
            
            if let languageError = languageLoadingError {
                languageLoadingState = .error
            }
        }
        
    }
}

extension RepositoryDetailView.ViewModel {
    enum LanguageLoadingState {
        case error
        case loading
        case loaded([RepoLanguage])
    }
    
    enum ContributorLoadingState {
        case error
        case loading
        case loaded([Contributor])
    }
}
