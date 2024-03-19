//
//  Repositories.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-19.
//

import Foundation

struct Repository: Codable, Hashable, Equatable {
    let name: String
    let owner: RepositoryOwner
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
    
}

struct RepositoryOwner: Codable, Hashable, Equatable {
    let username: String
    let avatarUrl: String
    let avatarData: Data? // This is most likely not necessary since I'll be caching anyways (but only cache the data that the user has interacted with e.g. visitting a profile)
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case avatarUrl = "avatar_url"
        case avatarData
    }
}


