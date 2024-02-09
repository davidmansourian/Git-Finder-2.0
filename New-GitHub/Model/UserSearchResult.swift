//
//  User.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation

public struct UserSearchResult: Codable {
    let resultsCount: Int
    let incompleteResults: Bool
    let users: [User]
    
    enum CodingKeys: String, CodingKey {
        case resultsCount = "total_count"
        case incompleteResults = "incomplete_results"
        case users = "items"
    }
}

public struct User: Codable, Identifiable {
    public let id: Int
    let username: String
    let avatarUrl: String
    let reposUrl: String
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case id
        case avatarUrl = "avatar_url"
        case reposUrl = "repos_url"
    }
}
