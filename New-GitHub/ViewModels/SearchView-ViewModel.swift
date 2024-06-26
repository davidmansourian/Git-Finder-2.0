//
//  ProfileResultsModel.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-17.
//

import Foundation
import SwiftUI

extension SearchView {
    @Observable
    public final class ViewModel {
        private let apiService: ApiServing
        private let avatarLoader: AvatarLoader
        private let profileAvatarHeight: CGFloat = 32
        
        private(set) var avatarImages = [String:UIImage]()
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
            
            await loadAvatarImages(for: users)
            
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
                        // print("Task was cancelled due to updated searchterm. Hiding error from user.")
                    }
                    
                    return nil
                }
            }
            
            self.searchTask = task
        }
        
        private func wasTaskCancelled(_ error: Error) -> Bool {
            error.localizedDescription == CustomApiError.unknownError("cancelled").localizedDescription || error.localizedDescription == "cancelled"
        }
        
        private func loadAvatarImages(for users: [User]?) async {
            guard let users = users else { return }
            if let loadedAvatars = try? await avatarLoader.loadAvatarImages(
                for: users,
                requestedHeight: 32
            ) {
                avatarImages = loadedAvatars
            }
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
