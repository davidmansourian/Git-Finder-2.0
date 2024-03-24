//
//  Contributor.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import Foundation

struct Contributor: Codable, Hashable {
    let username: String
    let avatarUrl: String
    let contributions: Int
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case avatarUrl = "avatar_url"
        case contributions
    }
}
