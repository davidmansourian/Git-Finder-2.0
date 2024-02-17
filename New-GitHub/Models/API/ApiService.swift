//
//  ApiService.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-07.
//

import Foundation
import SwiftUI

protocol ApiServing {
    func fetchUserResults(for searchTerm: String) async throws -> UserSearchResult
    func fetchDataType(for urlString: String) async throws -> Data
}

@Observable
public final class ApiService: HTTPDataDownloading, ApiServing {
    
    // https://api.github.com/users?q=SEARCHTERM
    public func fetchUserResults(for searchTerm: String) async throws -> UserSearchResult {
        return try await fetchData(as: UserSearchResult.self, from: "https://api.github.com/search/users?q=\(searchTerm)")
    }
    
    public func fetchDataType(for urlString: String) async throws -> Data {
        return try await fetchRawData(from: urlString)
    }
    
}
