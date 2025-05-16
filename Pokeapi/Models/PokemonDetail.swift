//
//  PokemonDetail.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import Foundation
import SwiftUI

struct PokemonDetail: Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites
    let types: [TypeElement]
    let stats: [Stat]
    
    var imageURL: URL? {
        if let artworkURLString = sprites.other?.officialArtwork?.frontDefault,
           let url = URL(string: artworkURLString), !artworkURLString.isEmpty {
            return url
        }

        if let fallbackURLString = sprites.frontDefault,
           let url = URL(string: fallbackURLString), !fallbackURLString.isEmpty {
            return url
        }

        return nil
    }
}

struct Sprites: Codable {
    let frontDefault: String?
    let other: OtherSprites?
    
    private enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case other
    }
}

struct OtherSprites: Codable {
    let officialArtwork: OfficialArtwork?
    
    private enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable {
    let frontDefault: String?
    
    private enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct TypeElement: Codable {
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
    
    var color: Color {
        switch name {
        case "grass": return .green
        case "fire": return .red
        case "water": return .blue
        case "electric": return .yellow
        case "psychic": return .purple
        case "ice": return .cyan
        case "dragon": return .orange
        case "dark": return .black
        case "fairy": return .pink
        default: return .gray
        }
    }
}

struct Stat: Codable {
    let baseStat: Int
    let stat: StatInfo
    
    private enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

struct StatInfo: Codable {
    let name: String
}
