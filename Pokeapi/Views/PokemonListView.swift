//
//  PokemonListView.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel()
    @State private var selectedPokemon: Pokemon?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    // Toggle for method change
                    HStack {
                        Toggle("Use Combine", isOn: $viewModel.useCombine)
                        Text(viewModel.useCombine ? "(Combine)" : "(Async/Await)")
                            .frame(width: 80)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .onChange(of: viewModel.useCombine) {
                        viewModel.loadPokemonList()
                    }
                    
                    if viewModel.isLoading && viewModel.pokemonList.isEmpty {
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity, minHeight: 400)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(viewModel.pokemonList) { pokemon in
                                PokemonCard(pokemon: pokemon)
                                    .onTapGesture {
                                        selectedPokemon = pokemon
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Pokemon List")
            .task {
                viewModel.loadPokemonList()
            }
            .sheet(item: $selectedPokemon) { pokemon in
                PokemonDetailView(pokemonId: pokemon.id, useCombine: viewModel.useCombine)
            }
        }
    }
}
