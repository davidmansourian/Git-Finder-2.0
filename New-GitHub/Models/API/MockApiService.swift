//
//  MockApiService.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation
import SwiftUI

class MockApiService: ApiServing {
    var cacheManager = CacheManager()
    var mockData: Data?
    var mockError: CustomApiError?
    
    func fetchUserResult(for searchTerm: String) async throws -> UserSearchResult {
        if let mockError { throw mockError }
        
        return try JSONDecoder().decode(UserSearchResult.self, from: mockData ?? mockSearch_userResultsData)
    }
    
    func fetchImageData(for urlString: String) async throws -> Data {
        let image = UIImage(named: "testAvatar")
        guard let jpegImageData = image?.jpegData(compressionQuality: 1.0) else { return Data() }
        return jpegImageData
    }
    
    func fetchUserInfo(for user: String) async throws -> User {
        return User(id: 1, username: "Test", avatarUrl: "testAvatarUrl", url: "testUrl", reposUrl: "testReposUrl", type: "User")
    }
    
    func fetchRepositories(for user: String, pageNumber: Int) async throws -> [Repository] {
        let fakeRepoOwner = RepositoryOwner(username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4")
        let fakeRepository = Repository(name: "Pelle's Project", owner: fakeRepoOwner, description: "I am Pelle. This is my project, and I am very proud of it.", starGazersCount: 12, watchersCount: 33, forksCount: 25)
        
        // Using to see shimmer in preview
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        return [fakeRepository]
    }
}
