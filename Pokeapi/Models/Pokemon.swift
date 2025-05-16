//
//  Pokemon.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import Foundation

struct PokemonResponse: Codable {
    let results: [Pokemon]
}

struct Pokemon: Codable, Identifiable {
    let name: String
    let url: String
    
    // Extracts the Pokémon ID from the URL string
    // Typical URL is like: "https://pokeapi.co/api/v2/pokemon/1/"
    // And pokemon ids start from one
    var id: Int {
        guard let url = URL(string: url) else { return 1 }

        for component in url.pathComponents.reversed() {
            if let number = Int(component) {
                return number
            }
        }

        return 1
    }
    
    func detailURL() -> URL? {
        PokeAPIEndpoint.url(for: .detail(id: id))
    }
    
    func thumbnailImageURL() -> URL? {
        PokeAPIEndpoint.url(for: .sprite(id: id))
    }
}
