//
//  CacheService.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import Foundation

protocol CacheServiceProtocol {
    func get<T: Codable>(forKey key: String) -> T?
    func set<T: Codable>(value: T, forKey key: String)
    func removeValue(forKey key: String)
    func clearAll()
}

class CacheService: CacheServiceProtocol {
    private let cache = NSCache<NSString, NSData>()
    
    func get<T: Codable>(forKey key: String) -> T? {
        guard let data = cache.object(forKey: key as NSString) as? Data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func set<T: Codable>(value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        cache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func removeValue(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func clearAll() {
        cache.removeAllObjects()
    }
    
    
}
