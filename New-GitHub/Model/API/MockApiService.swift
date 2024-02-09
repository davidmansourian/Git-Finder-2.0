//
//  MockApiService.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation

class MockApiService: ApiServing {
    func fetchUsernames(for searchTerm: String) async throws -> UserSearchResult {
        return UserSearchResult(resultsCount: 1, incompleteResults: false, users: [])
    }
    
    
}
