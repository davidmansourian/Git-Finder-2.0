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
        
        private(set) var repositories: [Repository]?
        private(set) var viewState: ViewState = .idle
        
        init(apiService: ApiServing, username: String) {
            self.apiService = apiService
            self.username = username
            
            Task { await loadUserDetails() }
        }
        
        // Cache fetched avatar image data
        // Means, profile avatar will always be fetched quickly
        
        // I should have a separate manager for fetching images that communicates with my cache manager. I think this is the best solution becuase I will be using this across a few separate view models
        
        // Regarding the page number, I need to check whether the fetched repos is < 30. If the repos are < 30, then I am on the last page, which means I shouldn't make any more api calls if I reach the end of the list
        // I can control this either through a boolean or an enum, then I can have a gurd statement within the function that handles the loading 
        private func loadUserDetails() async {
            do {
                let repos = try await apiService.fetchRepositories(for: username, pageNumber: repoResultsPageNumber)
                
                self.repositories = repos
            } catch {
                if let error = error as? CustomApiError {
                    print(error.customDescription)
                } else {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension ProfileView.ViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded(User)
        case error(String)
    }
}
