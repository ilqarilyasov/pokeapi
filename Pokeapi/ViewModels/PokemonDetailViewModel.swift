//
//  PokemonDetailViewModel.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import Foundation
import Combine

@MainActor
class PokemonDetailViewModel: ObservableObject {
    @Published var pokemonDetail: PokemonDetail?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var useCombine: Bool

    private let id: Int
    private let repository: PokemonRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(id: Int, useCombine: Bool, repository: PokemonRepositoryProtocol = PokemonRepository()) {
        self.id = id
        self.useCombine = useCombine
        self.repository = repository
        loadPokemonDetail()
    }

    func loadPokemonDetail() {
        // Reset state
        pokemonDetail = nil
        isLoading = true
        error = nil

        if useCombine {
            loadPokemonDetailCombine()
        } else {
            Task { await fetchPokemonDetailAsync() }
        }
    }

    private func fetchPokemonDetailAsync() async {
        do {
            let detail = try await repository.fetchPokemonDetail(id: id)
            await MainActor.run {
                pokemonDetail = detail
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }

    private func loadPokemonDetailCombine() {
        repository.fetchPokemonDetailPublisher(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    if case .failure(let err) = completion {
                        self.error = err
                    }
                },
                receiveValue: { [weak self] detail in
                    self?.pokemonDetail = detail
                }
            )
            .store(in: &cancellables)
    }
}
