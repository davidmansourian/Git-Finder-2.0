//
//  CacheManager.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-20.
//

import Foundation

protocol CacheManaging {
    func set<T: Encodable>(toCache data: T, forKey key: String)
    func get<T: Decodable>(as type: T.Type, forKey key: String) -> T?
}

extension CacheManager: CacheManaging {}

struct CacheManager {
   private let cache = NSCache<NSString, NSData>()
    
    public func set<T: Encodable>(toCache data: T, forKey key: String) {
        let dataToStore: Data
        
        if let data = data as? Data {
            dataToStore = data
        } else {
            guard let data = try? JSONEncoder().encode(data) else { return }
            dataToStore = data
        }
        
        cache.setObject(dataToStore as NSData, forKey: sanitizedCacheKey(key) as NSString)
    }
    
    public func get<T: Decodable>(as type: T.Type, forKey key: String) -> T? {
        guard let data = cache.object(forKey: sanitizedCacheKey(key) as NSString) as? Data else { return nil }
        return (type == Data.self) ? data as? T : try? JSONDecoder().decode(type.self, from: data)
    }
}

private extension CacheManager {
    private func sanitizedCacheKey(_ key: String) -> String {
        key
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "=", with: "_")
    }
}
