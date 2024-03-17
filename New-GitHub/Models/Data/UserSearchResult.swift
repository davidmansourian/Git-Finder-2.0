//
//  User.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation

public struct UserSearchResult: Codable, Equatable {
    let resultsCount: Int
    let incompleteResults: Bool
    let users: [User]
    
    enum CodingKeys: String, CodingKey {
        case resultsCount = "total_count"
        case incompleteResults = "incomplete_results"
        case users = "items"
    }
}

public struct User: Codable, Identifiable, Hashable, Equatable {
    public let id: Int?
    let username: String
    let avatarUrl: String
    let url: String
    let reposUrl: String
    let type: String
    let publicRepos: Int?
    var avatarImageData: Data?
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case id, type, url
        case avatarUrl = "avatar_url"
        case reposUrl = "repos_url"
        case publicRepos = "public_repos"
    }
}
