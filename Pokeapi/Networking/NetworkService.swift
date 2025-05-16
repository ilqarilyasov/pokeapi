//
//  NetworkService.swift
//  Pokeapi
//
//  Created by David on 2025-05-15.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case NetworkError(Error)
    case noData
}

protocol NetworkServiceProtocol {
    func fetchPokemonList() async throws -> [Pokemon]
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail
    
    func fetchPokemonListPublisher() -> AnyPublisher<[Pokemon], Error>
    func fetchPokemonDetailPublisher(id: Int) -> AnyPublisher<PokemonDetail, Error>
}

class NetworkService: NetworkServiceProtocol {
    static let shared: NetworkServiceProtocol = NetworkService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        self.session = URLSession(configuration: configuration)
        self.decoder = JSONDecoder()
    }
    
    private enum Constants {
        static let defaultLimit = 151
    }
    
    // MARK: - Async / await
    
    func fetchPokemonList() async throws -> [Pokemon] {
        guard let url = PokeAPIEndpoint.url(for: .list(limit: Constants.defaultLimit)) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(PokemonResponse.self, from: data)
        return response.results
    }
    
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        guard let url = PokeAPIEndpoint.url(for: .detail(id: id)) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return try decoder.decode(PokemonDetail.self, from: data)
    }
    
    
    // MARK: - Combine
    
    func fetchPokemonListPublisher() -> AnyPublisher<[Pokemon], Error> {
        guard let url = PokeAPIEndpoint.url(for: .list(limit: Constants.defaultLimit)) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PokemonResponse.self, decoder: decoder)
            .map(\.results)
            .eraseToAnyPublisher()
    }
    
    func fetchPokemonDetailPublisher(id: Int) -> AnyPublisher<PokemonDetail, Error> {
        guard let url = PokeAPIEndpoint.url(for: .detail(id: id)) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PokemonDetail.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
