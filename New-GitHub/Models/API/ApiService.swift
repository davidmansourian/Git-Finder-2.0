//
//  ApiService.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-07.
//

import Foundation
import SwiftUI

protocol ApiServing {
    func fetchUserResult(for searchTerm: String) async throws -> UserSearchResult
    func fetchDataType(for urlString: String) async throws -> Data
    func fetchUserInfo(for user: String) async throws -> User
    func fetchRepositories(for user: String, pageNumber: Int) async throws -> [Repository]
}

struct ApiService: HTTPDataDownloading, ApiServing {
    public func fetchUserResult(for searchTerm: String) async throws -> UserSearchResult {
        guard let endpoint = userSearchUrl(for: searchTerm) else { throw CustomApiError.badURL }
        return try await fetchData(as: UserSearchResult.self, from: endpoint)
    }
    
    public func fetchDataType(for urlString: String) async throws -> Data {
        try await fetchData(as: Data.self, from: urlString)
    }
    
    public func fetchUserInfo(for user: String) async throws -> User {
        guard let endpoint = userProfileUrl(for: user) else { throw CustomApiError.badURL }
        return try await fetchData(as: User.self, from: endpoint)
    }
    
    public func fetchRepositories(for user: String, pageNumber: Int) async throws -> [Repository] {
        guard let endpoint = repositoryUrl(for: user, page: pageNumber) else { throw CustomApiError.badURL }
        return try await fetchData(as: [Repository].self, from: endpoint)
    }
}

extension ApiService {
    // https://api.github.com/search/users?q=SEARCHTERM
    private var baseUrlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        
        return components
    }
    
    private func userSearchUrl(for searchTerm: String) -> String? {
        var components = baseUrlComponents
        components.path += "/search/users"
        
        components.queryItems = [
            .init(name: "q", value: searchTerm)
        ]
        
        return components.url?.absoluteString
    }
    
    private func userProfileUrl(for user: String) -> String? {
        var components = baseUrlComponents
        components.path += "/users/\(user)"
        
        return components.url?.absoluteString
    }
    
    // https://api.github.com/users/apple/repos?type=all&sort=updated&affiliation=collaborator&page=1&per_page=100
    // https://api.github.com/users/apple/repos?type=all&page=1&per_page=100
    private func repositoryUrl(for user: String, page: Int) -> String? {
        var components = baseUrlComponents
        components.path += "/users/\(user)/repos"
        
        components.queryItems = [
            .init(name: "type", value: "all"),
            .init(name: "page", value: String(page)),
            .init(name: "per_page", value: "30")
        ]
        
        return components.url?.absoluteString
    }
}
