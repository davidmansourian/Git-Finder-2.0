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
        private let injectedUser: User
        
        private(set) var viewState: ViewState = .idle
        
        init(apiService: ApiServing, injectedUser: User) {
            self.apiService = apiService
            self.injectedUser = injectedUser
        }
        
        private func loadUser() {
            
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
