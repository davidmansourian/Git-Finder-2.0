//
//  MockApiService.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation
import SwiftUI

class MockApiService: ApiServing {
    var cacheManager: CacheManaging
    var mockData: Data?
    var mockError: CustomApiError?
    var latestFetchWasFromCache = false
    
    init(cacheManager: CacheManaging) {
        self.cacheManager = cacheManager
    }
    
    func fetchUserResult(for searchTerm: String) async throws -> UserSearchResult {
        if let mockError { throw mockError }
        
        return try JSONDecoder().decode(UserSearchResult.self, from: mockData ?? mockSearch_userResultsData)
    }
    
    func fetchImageData(for urlString: String) async throws -> Data {
        if let mockError { throw mockError }
        
        if let cachedImageData = cacheManager.get(as: Data.self, forKey: urlString) {
            latestFetchWasFromCache = true
            return cachedImageData
        }
        
        let image = UIImage(named: "testAvatar")
        guard let jpegImageData = image?.jpegData(compressionQuality: 1.0) else { return Data() }
        cacheManager.set(toCache: jpegImageData, forKey: urlString)
        
        return jpegImageData
    }
    
    func fetchUserInfo(for user: String) async throws -> User {
        return User(id: 1, username: "Test", avatarUrl: "testAvatarUrl", url: "testUrl", reposUrl: "testReposUrl", type: "User")
    }
    
    func fetchRepositories(for user: String, pageNumber: Int) async throws -> [Repository] {
        if let mockError { throw mockError }
        
        return mockData_thirtyMockRepos
        
        // Using to see shimmer in preview
        //try await Task.sleep(nanoseconds: 3_000_000_000)
    }
}
