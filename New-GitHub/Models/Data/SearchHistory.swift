//
//  SearchHistory.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import Foundation
import SwiftData

@Model
public class SearchHistory {
    var username: String
    var lastVisited: Date
    var avatarData: Data
    
    init(username: String, lastVisited: Date, avatarData: Data) {
        self.username = username
        self.lastVisited = lastVisited
        self.avatarData = avatarData
    }
}
