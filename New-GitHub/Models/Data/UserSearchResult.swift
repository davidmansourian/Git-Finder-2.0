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
    let users: [UserItem]
    
    enum CodingKeys: String, CodingKey {
        case resultsCount = "total_count"
        case incompleteResults = "incomplete_results"
        case users = "items"
    }
}

public struct UserItem: Codable, Identifiable, Hashable, Equatable {
    public let id: Int?
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
