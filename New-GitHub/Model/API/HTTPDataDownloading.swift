//
//  HTTPDataDownloading.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation

public protocol HTTPDataDownloading {
    func fetchData<T: Decodable>(as type: T.Type, for endpoint: String) async throws -> T
}

extension HTTPDataDownloading {
    public func fetchData<T: Decodable>(as type: T.Type, for endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw CustomApiError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        if let json = String(data: data, encoding: .utf8) {
            print(json)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CustomApiError.badServerResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw CustomApiError.invalidStatusCode(httpResponse.statusCode)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(type, from: data)
            return decodedData
        } catch {
            throw error as? CustomApiError ?? CustomApiError.unknownError(error.localizedDescription)
        }
    }
}
