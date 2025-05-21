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
    @Namespace private var cardAnimation
    
    // Grig config
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Bg color
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        implementationToggle
                        
                        if viewModel.isLoading && viewModel.pokemonList.isEmpty {
                            loadingView
                        } else {
                            pokemonGrid
                        }
                    }
                    .padding(.horizontal)
                }
                .refreshable {
                    viewModel.loadPokemonList(forceRefresh: true)
                }
                .navigationTitle("Pokemon list")
                .task {
                    viewModel.loadPokemonList()
                }
                .sheet(item: $selectedPokemon) { pokemon in
                    PokemonDetailView(pokemonId: pokemon.id, useCombine: viewModel.useCombine)
                }
                .animation(.spring(), value: viewModel.pokemonList)
                .animation(.spring(), value: viewModel.isLoading)
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private var implementationToggle: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Toggle("Method", isOn: $viewModel.useCombine)
                Spacer()
                Text(viewModel.useCombine ? "(Combine)" : "(Async/Await)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 100, alignment: .trailing)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemGroupedBackground))
            }
            .onChange(of: viewModel.useCombine) {
                viewModel.loadPokemonList()
            }
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
    
    @ViewBuilder
    private var pokemonGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.pokemonList) { pokemon in
                PokemonCard(pokemon: pokemon)
                    .matchedGeometryEffect(id: pokemon.id, in: cardAnimation, isSource: true)
                    .onTapGesture {
                        selectedPokemon = pokemon
                    }
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical)
    }
}
