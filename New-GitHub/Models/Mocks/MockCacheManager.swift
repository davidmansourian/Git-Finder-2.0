//
//  MockCacheManager.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-23.
//

import Foundation

class MockCacheManager: CacheManaging {
    private var cache: [String: Data] = [:]
    
    func set<T: Encodable>(toCache data: T, forKey key: String) {
        let dataToStore: Data
        
        if let data = data as? Data {
            dataToStore = data
        } else {
            guard let data = try? JSONEncoder().encode(data) else { return }
            dataToStore = data
        }
        
        cache[sanitizedCacheKey(key)] = dataToStore
    }
    
    func get<T: Decodable>(as type: T.Type, forKey key: String) -> T? {
        guard let data = cache[sanitizedCacheKey(key)] else { return nil }
        return (type == Data.self) ? data as? T : try? JSONDecoder().decode(type.self, from: data)
    }
}

private extension MockCacheManager {
    private func sanitizedCacheKey(_ key: String) -> String {
        key
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "=", with: "_")
    }
}
