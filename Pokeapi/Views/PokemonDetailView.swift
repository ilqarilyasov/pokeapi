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

    init(pokemonId: Int, useCombine: Bool) {
        _viewModel = StateObject(
            wrappedValue: PokemonDetailViewModel(id: pokemonId, useCombine: useCombine)
        )
    }

    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                VStack {
                    ProgressView("Loading details...")
                    Text("Using \(viewModel.useCombine ? "Combine" : "Async/Await")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                    Text("Error loading Pokémon")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        viewModel.loadPokemonDetail()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if let pokemon = viewModel.pokemonDetail {
                ScrollView {
                    VStack(spacing: 20) {
                        // Image
                        AsyncImage(url: pokemon.imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxHeight: 200)

                        // Types
                        HStack {
                            ForEach(pokemon.types, id: \.type.name) { typeElement in
                                Text(typeElement.type.name.capitalized)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .foregroundStyle(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(typeElement.type.color))
                                    )
                            }
                        }

                        // Basic info
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

                        // Stats
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Base Stats")
                                .font(.headline)
                            ForEach(pokemon.stats, id: \.stat.name) { stat in
                                HStack {
                                    Text(stat.stat.name.replacingOccurrences(of: "-", with: " ").capitalized)
                                        .frame(width: 120, alignment: .leading)
                                        .font(.caption)
                                    ProgressView(value: Double(stat.baseStat), total: 255)
                                    Text("\(stat.baseStat)")
                                        .font(.caption)
                                        .frame(width: 40)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(viewModel.pokemonDetail?.name.capitalized ?? "Pokemon Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
