//
//  ApiService.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-07.
//

import Foundation

@Observable
public final class ApiService: HTTPDataDownloading {
    
    // https://api.github.com/users?q=SEARCHTERM
    public func fetchUsernames(for searchTerm: String) async throws -> UserSearchResult {
        return try await fetchData(as: UserSearchResult.self, for: "https://api.github.com/search/users?q=\(searchTerm)")
    }
    
}
