//
//  ProfileResultsModel.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-17.
//

import Foundation

extension SearchView {
    @Observable
    public final class ViewModel {
        private let apiService: ApiServing
        
        private(set) var searchTask: Task<[User]?, Error>?
        private(set) var users: [User]?
        private(set) var viewState: ViewState = .idle
        
        init(apiService: ApiServing) {
            self.apiService = apiService
        }
        
        public func handleSearch(for searchTerm: String) async {
            guard !searchTerm.isEmpty else {
                users = nil
                return
            }
            
            await searchTask(for: searchTerm)
        }
        
        public func cancelSearchTask() {
            searchTask?.cancel()
        }
        
        private func searchTask(for searchTerm: String) async {
            let task = Task(priority: .userInitiated) { [weak self] in
                /// Debounce for 0.5 seconds
                try await Task.sleep(for: .seconds(0.5))
                
                self?.viewState = .loading
                do {
                    print("Getting userResults for \(searchTerm)")
                    let userResults = try await self?.apiService.fetchUserResults(for: searchTerm)
                    return try await self?.usersWithLoadedAvatars(for: userResults)
                } catch {
                    print((error as? CustomApiError)?.customDescription ?? error.localizedDescription)
                    
                    return nil
                }
                
            }
            
            self.searchTask = task
            
            await updateUserResults()
            
            viewState = .idle
        }
        
        @MainActor private func updateUserResults() async {
            do {
                self.users = try await searchTask?.value
            } catch {
//                print("Task error: \(error.localizedDescription)")
            }
        }
        
        private func usersWithLoadedAvatars(for userResults: UserSearchResult?) async throws -> [User]? {
            guard let userResults = userResults else { return nil }
            var users: [User] = []
            
            for user in userResults.users {
                let imageData = try await apiService.fetchDataType(for: user.avatarUrl)
                
                let newUser = User(username: user.username, avatarUrl: user.avatarUrl, reposUrl: user.reposUrl, avatarImageData: imageData)
                
                users.append(newUser)
            }
            
            return users
        }
    }
}

extension SearchView.ViewModel {
        enum ViewState {
            case idle, loading
            case error(String)
        }
}
