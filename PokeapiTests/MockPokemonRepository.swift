//
//  MockPokemonRepository.swift
//  PokeapiTests
//
//  Created by David on 2025-05-16.
//

import Foundation
import Combine
@testable import Pokeapi

class MockPokemonRepository: PokemonRepositoryProtocol {
    var shouldSucceed = true
    var mockPokemonList: [Pokemon] = []
    var mockPokemonDetail: PokemonDetail?
    var mockError: Error = NetworkError.noData
    
    // MARK: - Async/Await Methods
    
    func fetchPokemonList() async throws -> [Pokemon] {
        if shouldSucceed {
            return mockPokemonList
        } else {
            throw mockError
        }
    }
    
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        if shouldSucceed {
            guard let detail = mockPokemonDetail else {
                throw NetworkError.noData
            }
            return detail
        } else {
            throw mockError
        }
    }
    
    // MARK: - Combine Methods
    
    func fetchPokemonListPublisher() -> AnyPublisher<[Pokemon], Error> {
        if shouldSucceed {
            return Just(mockPokemonList)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchPokemonDetailPublisher(id: Int) -> AnyPublisher<PokemonDetail, Error> {
        if shouldSucceed {
            guard let detail = mockPokemonDetail else {
                return Fail(error: NetworkError.noData)
                    .eraseToAnyPublisher()
            }
            return Just(detail)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .eraseToAnyPublisher()
        }
    }
    
    func clearCache() {}
}
