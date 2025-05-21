//
//  PokemonListViewModel.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import Foundation
import Combine

@MainActor
class PokemonListViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var useCombine: Bool = false
    
    private let repository: PokemonRepositoryProtocol
    private var cancellables: [AnyCancellable] = []
    
    init(repository: PokemonRepositoryProtocol = PokemonRepository()) {
        self.repository = repository
    }
    
    func loadPokemonList(forceRefresh: Bool = false) {
        if forceRefresh {
            repository.clearCache()
        }
        
        // Reset state before loading
        pokemonList = []
        isLoading = false
        error = nil
        
        if useCombine {
            loadPokemonListCombine()
        } else {
            Task {
                await fetchPokemonListAsync()
            }
        }
    }
    
    private func fetchPokemonListAsync() async {
        isLoading = true
        error = nil
        
        do {
            pokemonList = try await repository.fetchPokemonList()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    private func loadPokemonListCombine() {
        isLoading = true
        error = nil
        
        repository.fetchPokemonListPublisher()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                }, receiveValue: { [weak self] list in
                    self?.pokemonList = list
                }
            ).store(in: &cancellables)
    }
}
