//
//  PokemonRepository.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import Foundation
import Combine

protocol PokemonRepositoryProtocol {
    func fetchPokemonList() async throws -> [Pokemon]
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail
    
    func fetchPokemonListPublisher() -> AnyPublisher<[Pokemon], Error>
    func fetchPokemonDetailPublisher(id: Int) -> AnyPublisher<PokemonDetail, Error>
    
    func clearCache()
}

class PokemonRepository: PokemonRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         cacheService: CacheServiceProtocol = CacheService()) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    private enum Constants {
        enum CacheKeys {
            static let pokemonList = "pokemon_list"
            static func pokemonDetail(id: Int) -> String { "pokemon_detail_\(id)" }
        }
    }
    
    func fetchPokemonList() async throws -> [Pokemon] {
        // First check cache
        if let cachedList: [Pokemon] = cacheService.get(forKey: Constants.CacheKeys.pokemonList) {
            return cachedList
        }
        
        // Fetch from network
        let list = try await networkService.fetchPokemonList()
        cacheService.set(value: list, forKey: Constants.CacheKeys.pokemonList)
        return list
    }
    
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        let cacheKey = Constants.CacheKeys.pokemonDetail(id: id)
        
        if let cachedDetail: PokemonDetail = cacheService.get(forKey: cacheKey) {
            return cachedDetail
        }
        
        let detail = try await networkService.fetchPokemonDetail(id: id)
        cacheService.set(value: detail, forKey: cacheKey)
        return detail
    }
    
    func fetchPokemonListPublisher() -> AnyPublisher<[Pokemon], Error> {
        if let cachedList: [Pokemon] = cacheService.get(forKey: Constants.CacheKeys.pokemonList) {
            return Just(cachedList)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return networkService.fetchPokemonListPublisher()
            .handleEvents(receiveOutput: { [weak self] list in
                self?.cacheService.set(value: list, forKey: Constants.CacheKeys.pokemonList)
            })
            .eraseToAnyPublisher()
    }
    
    func fetchPokemonDetailPublisher(id: Int) -> AnyPublisher<PokemonDetail, any Error> {
        let cacheKey = Constants.CacheKeys.pokemonDetail(id: id)
        
        if let cachedDetail: PokemonDetail = cacheService.get(forKey: cacheKey) {
            return Just(cachedDetail)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return networkService.fetchPokemonDetailPublisher(id: id)
            .handleEvents(receiveOutput: { [weak self] detail in
                self?.cacheService.set(value: detail, forKey: cacheKey)
            })
            .eraseToAnyPublisher()
    }
    
    func clearCache() {
        cacheService.clearAll()
    }
}
