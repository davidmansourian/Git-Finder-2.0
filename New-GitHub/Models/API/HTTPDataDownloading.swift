//
//  HTTPDataDownloading.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation

public protocol HTTPDataDownloading {
    func fetchData<T: Decodable>(as type: T.Type, from endpoint: String) async throws -> T
    func fetchRawData(from endpoint: String) async throws -> Data
}

extension HTTPDataDownloading {
    public func fetchData<T: Decodable>(as type: T.Type, from endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw CustomApiError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        //print(String(data: data, encoding: .utf8))
        
        try validateResponse(response)
        
        do {
            let decodedData = try JSONDecoder().decode(type, from: data)
            return decodedData
        } catch {
            throw error as? CustomApiError ?? CustomApiError.unknownError(error.localizedDescription)
        }
    }
    
    public func fetchRawData(from endpoint: String) async throws -> Data {
        guard let url = URL(string: endpoint) else {
            throw CustomApiError.badURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            try validateResponse(response)
            
            return data
        } catch {
            throw error as? CustomApiError ?? CustomApiError.unknownError(error.localizedDescription)
        }
    }
    
    private func validateResponse(_ response: URLResponse?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CustomApiError.badServerResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw CustomApiError.invalidStatusCode(httpResponse.statusCode)
        }
    }
}
