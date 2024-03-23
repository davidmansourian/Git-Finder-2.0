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
        private let avatarLoader: AvatarLoader
        private let profileAvatarHeight: CGFloat = 32
        
        private(set) var searchTask: Task<[User]?, Error>?
        private(set) var state: State = .idle
        
        private var searchError: String?
        
        init(apiService: ApiServing, avatarLoader: AvatarLoader) {
            self.apiService = apiService
            self.avatarLoader = avatarLoader
        }
        
        public func cancelSearchTask() {
            searchTask?.cancel()
        }
        
        public func handleSearch(for searchTerm: String) async {
            searchError = nil
            
            guard !searchTerm.isEmpty else {
                self.state = .idle
                return
            }
            
            self.state = .loading
            
            await performSearch(for: searchTerm)
            
            let users = try? await searchTask?.value
            await avatarLoader.loadImageDatas(for: users, requestedHeight: 32)
            await updateUserResults(users)
        }
                
        private func performSearch(for searchTerm: String) async {
            let task = Task(priority: .userInitiated) { [weak self] in
                try await Task.sleep(for: .seconds(0.4))
                
                do {
                    print("Getting userResults for \(searchTerm)")
                    let userResults = try await self?.apiService.fetchUserResult(for: searchTerm)
                    return userResults?.users
                    
                } catch {
                    /// Check so that error is not task cancelled
                    if self?.wasTaskCancelled(error) == false {
                        self?.searchError = error.localizedDescription
                    } else {
                        print("Task was cancelled due to updated searchterm. Hiding error from user.")
                    }
                    
                    return nil
                }
            }
            
            self.searchTask = task
        }
        
//        private func loadImageDatas(for userResults: [User]?) async {
//            guard let users = userResults else { return }
//            await withTaskGroup(of: (String, Data).self) { [weak self] taskGroup in
//                guard let self = self else { return }
//                for user in users {
//                    let imageUrl = user.avatarUrl
//                    await avatarLoader.storeImageDatasIfNecessary(
//                        for: user.username,
//                        with: imageUrl,
//                        currentView: .search,
//                        requestedHeight: profileAvatarHeight
//                    )
//                }
//            }
//        }
        
        private func wasTaskCancelled(_ error: Error) -> Bool {
            error.localizedDescription == CustomApiError.unknownError("cancelled").localizedDescription || error.localizedDescription == "cancelled"
        }

        @MainActor
        private func updateUserResults(_ userResults: [User]?) async {
            if let users = userResults {
                self.state = .loaded(users)
            } else if let error = searchError {
                self.state = .error(error)
            }
        }
    }
}

extension SearchView.ViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([User])
        case error(String)
    }
}
