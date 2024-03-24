//
//  ProfileView-ViewModel.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-17.
//

import Foundation
import SwiftUI

extension ProfileView {
    @Observable
    public final class ViewModel {
        private let apiService: ApiServing
        private let avatarLoader: AvatarLoader
        private let repoOwnerAvatarHeight: CGFloat = 18
        
        private var loadingError: String?
        private var repositories: [Repository]?
        private var repoResultsPageNumber = 1
        private var username: String
        
        private(set) var avatarImages = [String: UIImage]()
        private(set) var loadingTask: Task<Void, Never>?
        private(set) var repoCount = 0
        private(set) var scrollLoading = false
        private(set) var state: State = .loading
        
        init(apiService: ApiServing, avatarLoader: AvatarLoader, username: String) {
            self.apiService = apiService
            self.avatarLoader = avatarLoader
            self.username = username
            
            loadInitialRepos()
        }
        
        // Should I cache the repos?
        // I could cache 30 items at a time, and store the key as username_page_1 or something similar. In the api call, I check whether the page number for the username's repo is already cached
        // Not sure if necessary tho
        
        private func loadInitialRepos() {
            Task { [weak self] in
                guard let self = self else { return }
                self.loadingError = nil
                do {
                    self.repositories = try await fetchReposAndAvatars()
                    await setUserResultsWithFilterAndSort(.all, .originalOrder)
                } catch {
                    self.loadingError = error.localizedDescription
                }
            }
        }
        
        @MainActor
        private func fetchReposAndAvatars() async throws -> [Repository] {
            let newRepos = try await apiService.fetchRepositories(
                for: username,
                pageNumber: repoResultsPageNumber
            )
            
            if let loadedAvatars = try? await avatarLoader.loadAvatarImages(
                for: newRepos,
                requestedHeight: repoOwnerAvatarHeight,
                currentAvatars: avatarImages
            ) {
                avatarImages = loadedAvatars
            }
            
            return newRepos
        }
        
        public func scrollRepositories(consider filterState: FilterState, and sortState: SortState) {
            guard shouldFetchMoreRepositories else { return }
            
            loadingTask = Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                try? await Task.sleep(for: .seconds(0.2))
                scrollLoading = true
                do {
                    repoResultsPageNumber += 1
                    let newRepos = try await self.fetchReposAndAvatars()
                    self.repositories?.append(contentsOf: newRepos)
                    await setUserResultsWithFilterAndSort(filterState, sortState)
                } catch {
                    //print("Error scrolling repositories: \(error.localizedDescription)")
                }
                scrollLoading = false
            }
        }
        
        private var shouldFetchMoreRepositories: Bool {
            guard let repos = self.repositories else { return false }
            return repos.count % 30 == 0 // If total repo count is not a multiple of 30, then I am on the last page
        }
        
        public func setUserResultsWithFilterAndSort(_ filterState: FilterState, _ sortState: SortState) async {
            guard let filteredRepos = filterRepos(filterState) else { return }
            
            let filteredAndSortedRepos = sortRepos(sortState: sortState, filteredRepos: filteredRepos)
            
            await updateUserState(filteredAndSortedRepos)
        }
        
        private func filterRepos(_ filterState: FilterState) -> [Repository]? {
            switch filterState {
            case .all:
                return self.repositories
            case .owner:
                return self.repositories?.filter { $0.owner.username == username }
            case .contributor:
                return self.repositories?.filter { $0.owner.username != username }
            }
        }
        
        private func sortRepos(sortState: SortState, filteredRepos: [Repository]) -> [Repository]? {
            switch sortState {
            case .watchersAscending:
                return filteredRepos.sorted(by: {$0.watchersCount < $1.watchersCount})
            case .watchersDescending:
                return filteredRepos.sorted(by: {$0.watchersCount > $1.watchersCount})
            case .latest:
                return filteredRepos.sorted(by: {dateFromISOString($0.lastUpdated) ?? .now > dateFromISOString($1.lastUpdated) ?? .now})
            case .oldest:
                return filteredRepos.sorted(by: {dateFromISOString($0.lastUpdated) ?? .now < dateFromISOString($1.lastUpdated) ?? .now})
            case .originalOrder:
                return filteredRepos
            }
        }
        
        // taken from: https://www.hackingwithswift.com/forums/swift/how-to-convert-string-into-date/14396/14401
        private func dateFromISOString(_ isoString: String) -> Date? {
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withFullDate]
            return isoDateFormatter.date(from: isoString)
        }
        
        @MainActor
        private func updateUserState(_ repositories: [Repository]?) async {
            if let repos = repositories {
                self.repoCount = repos.count
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
