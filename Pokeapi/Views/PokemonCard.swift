//
//  PokemonCard.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import SwiftUI

struct PokemonCard: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack {
            AsyncImage(url: pokemon.thumbnailImageURL()) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            
            Text(pokemon.name.capitalized)
                .font(.caption)
                .lineLimit(1)
            
            Text("#\(String(format: "%03d", pokemon.id))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        }
    }
}
