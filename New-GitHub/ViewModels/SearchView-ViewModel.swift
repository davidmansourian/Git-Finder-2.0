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

        /// https://forums.swift.org/t/observable-macro-conflicting-with-mainactor/67309
        @MainActor
        private func updateUserResults() async {
            if let users = try? await searchTask?.value {
                self.viewState = .loaded(users)
            } else if let error = searchError {
                self.viewState = .error(error)
            }
        }
        
        private func usersWithLoadedAvatars(for userResults: UserSearchResult?) async throws -> [User]? {
            guard let userResults = userResults else { return nil }
            var users: [User] = []
            
            for user in userResults.users {
                let imageData = try await apiService.fetchDataType(for: user.avatarUrl)
                
                let newUser = User(id: user.id, username: user.username, avatarUrl: user.avatarUrl, url: user.url, reposUrl: user.reposUrl, type: user.type, publicRepos: user.publicRepos, avatarImageData: imageData)
                
                users.append(newUser)
            }
            
            return users
        }
        
        // Concurrent solution using task group. For the small amout of images, not necessary as code is less readable.
//        private func usersWithLoadedAvatars(for userResults: UserSearchResult?) async throws -> [User]? {
//            guard let userResults = userResults else { return nil }
//            
//            let users = await withTaskGroup(of: (Int, User, Data?).self, returning: [User].self) { taskGroup in
//                for (index, user) in userResults.users.enumerated() {
//                    taskGroup.addTask {
//                        let imageData = try? await self.apiService.fetchDataType(for: user.avatarUrl)
//                        return (index, user, imageData)
//                    }
//                }
//                
//                var tempUsers: [Int: User] = [:]
//                
//                for await (index, user, imageData) in taskGroup {
//                    let newUser = User(id: user.id, username: user.username, avatarUrl: user.avatarUrl, reposUrl: user.reposUrl, type: user.type, avatarImageData: imageData)
//                    tempUsers[index] = newUser
//                }
//                
//                let sortedUsers = tempUsers.sorted(by: {$0.key < $1.key}).map {$0.value}
//                
//                return sortedUsers
//            }
//            
//            return users
//        }
    }
}

extension SearchView.ViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded([User])
        case error(String)
    }
    
    private func wasTaskCancelled(_ error: Error) -> Bool {
        ((error as? CustomApiError)?.customDescription == CustomApiError.unknownError("cancelled").customDescription) || (error.localizedDescription == "cancelled")
    }
}
