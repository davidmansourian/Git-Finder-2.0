//
//  Repositories.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-19.
//

import Foundation

struct Repository: Codable, Hashable, Equatable {
    let name: String
    let owner: Owner
    let description: String?
    let starGazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "full_name"
        case owner, description
        case starGazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
    }
    
    struct Owner: Codable, Hashable, Equatable {
        let username: String
        let avatarUrl: String
        
        enum CodingKeys: String, CodingKey {
            case username = "login"
            case avatarUrl = "avatar_url"
        }
    }
    
}

