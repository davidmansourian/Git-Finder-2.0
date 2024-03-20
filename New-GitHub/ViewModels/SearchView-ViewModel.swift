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
        private(set) var viewState: ViewState = .idle
        
        private var searchError: String?
        
        init(apiService: ApiServing) {
            self.apiService = apiService
        }
        
        public func cancelSearchTask() {
            searchTask?.cancel()
        }
        
        public func handleSearch(for searchTerm: String) async {
            searchError = nil
            
            guard !searchTerm.isEmpty else {
                self.viewState = .idle
                return
            }
            
            self.viewState = .loading
            
            await performSearch(for: searchTerm)
            await updateUserResults()
        }
                
        private func performSearch(for searchTerm: String) async {
            let task = Task(priority: .userInitiated) { [weak self] in
                try await Task.sleep(for: .seconds(0.4))
                
                do {
                    print("Getting userResults for \(searchTerm)")
                    let userResults = try await self?.apiService.fetchUserResult(for: searchTerm)
                    return try await self?.usersWithLoadedAvatars(for: userResults)
                    
                } catch {
                    /// Check so that error is not task cancelled
                    if self?.wasTaskCancelled(error) == false {
                        self?.searchError = (error as? CustomApiError)?.customDescription ?? error.localizedDescription
                    } else {
                        print("Task was cancelled due to updated searchterm. Hiding error from user.")
                    }
                    
                    return nil
                }
            }
            
            self.searchTask = task
        }
        
        private func usersWithLoadedAvatars(for userResults: UserSearchResult?) async throws -> [User]? {
            guard let userResults = userResults else { return nil }
            
            let users = await withTaskGroup(of: (Int, User, Data?).self, returning: [User]?.self) { [weak self] taskGroup in
                guard let self = self else { return nil }
                for (index, user) in userResults.users.enumerated() {
                    taskGroup.addTask {
                        let imageData = try? await self.apiService.fetchImageData(for: user.avatarUrl)
                        return (index, user, imageData)
                    }
                }
                
                var tempUsers: [Int: User] = [:]
                
                for await (index, user, imageData) in taskGroup {
                    let newUser = User(id: user.id, username: user.username, avatarUrl: user.avatarUrl, url: user.url, reposUrl: user.reposUrl, type: user.type, avatarImageData: imageData)
                    tempUsers[index] = newUser
                }
                
                let sortedUsers = tempUsers.sorted(by: {$0.key < $1.key}).map {$0.value}
                
                return sortedUsers
            }
            
            return users
        }
        
        private func wasTaskCancelled(_ error: Error) -> Bool {
            ((error as? CustomApiError)?.customDescription == CustomApiError.unknownError("cancelled").customDescription) || (error.localizedDescription == "cancelled")
        }

        @MainActor
        private func updateUserResults() async {
            if let users = try? await searchTask?.value {
                self.viewState = .loaded(users)
            } else if let error = searchError {
                self.viewState = .error(error)
            }
        }
    }
}

extension SearchView.ViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded([User])
        case error(String)
    }
}
