//
//  User.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-23.
//

import Foundation

public struct User: Codable, Identifiable, Hashable {
    public let id: Int?
    let username: String
    let avatarUrl: String
    let url: String
    let reposUrl: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case id, type, url
        case avatarUrl = "avatar_url"
        case reposUrl = "repos_url"
    }
}
