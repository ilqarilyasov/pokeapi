//
//  PokemonDetailView.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    init(pokemonId: Int, useCombine: Bool) {
        _viewModel = StateObject(
            wrappedValue: PokemonDetailViewModel(id: pokemonId, useCombine: useCombine)
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else if let pokemonDetail = viewModel.pokemonDetail {
                    pokemonDetailContent(pokemonDetail)
                }
            }
            .navigationTitle(viewModel.pokemonDetail?.name.capitalized ?? "Pokemon detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                }
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private var backgroundGradient: some View {
        let colors = viewModel.pokemonDetail?.types.first.map {
            [Color($0.type.color).opacity(0.3), Color(.systemBackground)] } ?? [Color(.systemBackground)]
        LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.headline)
            Text("Using \(viewModel.useCombine ? "Combine" : "Async/Await")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(0.7))
    }
    
    @ViewBuilder
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.red)
                .symbolEffect(.pulse)
            Text("Error loading")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry") {
                withAnimation {
                    viewModel.loadPokemonDetail()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func pokemonDetailContent(_ pokemon: PokemonDetail) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                pokemonImageView(pokemon)
                typeBadges(pokemon)
                attributesView(pokemon)
                statsView(pokemon)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func pokemonImageView(_ pokemon: PokemonDetail) -> some View {
        AsyncImage(url: pokemon.imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .transition(.scale.combined(with: .opacity))
            case .failure:
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxHeight: 200)
    }
    
    @ViewBuilder
    private func typeBadges(_ pokemon: PokemonDetail) -> some View {
        HStack(spacing: 12) {
            ForEach(pokemon.types, id: \.type.name) { typeElement in
                Text(typeElement.type.name.capitalized)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                    .background(
                        Capsule()
                            .fill(Color(typeElement.type.color))
                    )
            }
        }
    }
    
    @ViewBuilder
    private func attributesView(_ pokemon: PokemonDetail) -> some View {
        HStack(spacing: 40) {
            VStack {
                Text("Height")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.1f m", Double(pokemon.height) / 10))
                    .font(.headline)
            }
            VStack {
                Text("Weight")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.1f kg", Double(pokemon.weight) / 10))
                    .font(.headline)
            }
        }
    }
    
    @ViewBuilder
    private func statsView(_ pokemon: PokemonDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Base Stats")
                .font(.headline)
            ForEach(pokemon.stats, id: \.stat.name) { stat in
                statRow(stat: stat)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    @ViewBuilder
    private func statRow(stat: Stat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(stat.stat.name.replacingOccurrences(of: "-", with: " ").capitalized)
                    .frame(width: 120, alignment: .leading)
                    .font(.caption)
                Spacer()
                Text("\(stat.baseStat)")
                    .font(.caption)
                    .frame(width: 40)
            }
            ProgressView(value: Double(stat.baseStat), total: 255)
                .tint(.blue)
        }
    }
}
