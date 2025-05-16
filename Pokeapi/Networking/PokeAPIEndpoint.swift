//
//  PokeAPIEndpoint.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import Foundation

enum PokeAPIEndpoint {
    
    // MARK: - Endpoint Types
    enum API {
        case list(limit: Int)
        case detail(id: Int)
    }
    
    enum Image {
        case sprite(id: Int)
        case officialArtwork(id: Int)
    }
    
    // MARK: - URL Construction
    
    static func url(for endpoint: API) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "pokeapi.co"
        
        switch endpoint {
        case .list(let limit):
            components.path = "/api/v2/pokemon"
            components.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        case .detail(let id):
            components.path = "/api/v2/pokemon/\(id)"
        }
        
        return components.url
    }
    
    static func url(for resource: Image) -> URL? {
        let baseURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon"
        
        switch resource {
        case .sprite(let id):
            return URL(string: "\(baseURL)/\(id).png")
        case .officialArtwork(let id):
            return URL(string: "\(baseURL)/other/official-artwork/\(id).png")
        }
    }
}
