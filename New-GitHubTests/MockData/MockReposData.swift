//
//  MockJSONRepos.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import Foundation


let mockData_mockRepoOwner = Repository.Owner(username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4")
let mockData_mockRepo = Repository(name: "Pelle's Project", owner: mockData_mockRepoOwner, description: "I am Pelle. This is my project, and I am very proud of it.", starGazersCount: 12, watchersCount: 33, forksCount: 25, lastUpdated: "2023-09-05T22:41:23Z")
let mockData_mockRepo_highestCount = Repository(name: "Pelle's Project", owner: mockData_mockRepoOwner, description: "I am Pelle. This is my project, and I am very proud of it.", starGazersCount: 12, watchersCount: 150, forksCount: 25, lastUpdated: "2023-09-05T22:41:23Z")

let mockData_mockRepo_latestDate = Repository(name: "Latest project", owner: mockData_mockRepoOwner, description: "I am Pelle. This is my project, and I am very proud of it.", starGazersCount: 12, watchersCount: 150, forksCount: 25, lastUpdated: "2024-09-05T22:41:23Z")

let mockData_mockRepo_oldestDate = Repository(name: "Oldest project", owner: mockData_mockRepoOwner, description: "I am Pelle. This is my project, and I am very proud of it.", starGazersCount: 12, watchersCount: 150, forksCount: 25, lastUpdated: "2020-09-05T22:41:23Z")

let mockData_thirtyMockRepos: [Repository] = [mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo_oldestDate, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo_highestCount, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo_latestDate, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo, mockData_mockRepo]

let mockData_oneMockRepo: [Repository] = [mockData_mockRepo]
