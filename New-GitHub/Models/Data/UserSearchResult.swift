//
//  User.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation

public struct UserSearchResult: Codable, Hashable {
    let resultsCount: Int
    let incompleteResults: Bool
    let users: [User]
    
    enum CodingKeys: String, CodingKey {
        case resultsCount = "total_count"
        case incompleteResults = "incomplete_results"
        case users = "items"
    }
}
