//
//  PokemonCard.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import SwiftUI

struct PokemonCard: View {
    let pokemon: Pokemon
    @Environment(\.colorScheme) private var colorScheme
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 8) {
            idBadge
            imageContainer
            Text(pokemon.name.capitalized)
                .font(.system(.subheadline, design: .rounded).bold())
                .lineLimit(1)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(height: 160)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private var idBadge: some View {
        Text("#\(String(format: "%03d", pokemon.id))")
            .font(.system(.caption, design: .rounded).weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
            }
            .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    private var imageContainer: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 90, height: 90)
            AsyncImage(url: pokemon.thumbnailImageURL()) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    .onAppear {
                        isLoading = true
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .transition(.scale.combined(with: .opacity))
                        .onAppear {
                            isLoading = false
                        }
                case .failure(_):
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .frame(width: 80, height: 80)
                        .onAppear {
                            isLoading = false
                        }
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var cardBackground: Color {
        colorScheme == .dark ?
        Color(UIColor.secondarySystemBackground) :
        Color(UIColor.systemBackground)
    }
}
