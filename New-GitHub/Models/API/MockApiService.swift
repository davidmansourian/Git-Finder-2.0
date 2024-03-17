//
//  MockApiService.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation

class MockApiService: ApiServing {
    var mockData: Data?
    var mockError: CustomApiError?
    
    func fetchUserResult(for searchTerm: String) async throws -> UserSearchResult {
        if let mockError { throw mockError }
        
        return try JSONDecoder().decode(UserSearchResult.self, from: mockData ?? mockSearch_userResultsData)
    }
    
    func fetchDataType(for urlString: String) async throws -> Data {
        return Data()
    }
}
