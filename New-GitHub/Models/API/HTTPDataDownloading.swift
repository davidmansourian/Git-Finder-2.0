//
//  HTTPDataDownloading.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation

public protocol HTTPDataDownloading {
    func fetchData<T: Decodable>(as type: T.Type, from endpoint: String) async throws -> T
}

extension HTTPDataDownloading {
    public func fetchData<T: Decodable>(as type: T.Type, from endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw CustomApiError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        //print(String(data: data, encoding: .utf8))
        
        try validateResponse(response)
        
        guard let validatedData = try validateData(for: type, from: data) else { throw CustomApiError.invalidData }
        
        return validatedData
    }
    
    private func validateResponse(_ response: URLResponse?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CustomApiError.badServerResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw CustomApiError.invalidStatusCode(httpResponse.statusCode)
        }
    }
    
    private func validateData<T: Decodable>(for type: T.Type, from data: Data) throws -> T? {
        if type == UserSearchResult.self {
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                throw CustomApiError.invalidData
            }
        } else {
            return data as? T
        }
    }
}
