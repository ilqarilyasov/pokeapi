//
//  PokemonListViewModelTests.swift
//  PokeapiTests
//
//  Created by David on 2025-05-16.
//

import XCTest
import Combine
@testable import Pokeapi

@MainActor
class PokemonListViewModelTests: XCTestCase {
    var viewModel: PokemonListViewModel!
    var mockRepository: MockPokemonRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPokemonRepository()
        viewModel = PokemonListViewModel(repository: mockRepository)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Async/Await Tests
    
    func testFetchPokemonListAsyncSuccess() async throws {
        // Given
        mockRepository.shouldSucceed = true
        mockRepository.mockPokemonList = [
            Pokemon(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
            Pokemon(name: "charmander", url: "https://pokeapi.co/api/v2/pokemon/4/")
        ]
        viewModel.useCombine = false
        
        // When
        let loadTask = Task { @MainActor in
            viewModel.loadPokemonList()
        }
        await loadTask.value
        
        // Wait for the internal async to complete
        await Task.yield()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.pokemonList.count, 2)
        XCTAssertEqual(viewModel.pokemonList.first?.name, "bulbasaur")
        XCTAssertNil(viewModel.error)
    }
    
    func testFetchPokemonListAsyncError() async throws {
        // Given
        mockRepository.shouldSucceed = false
        mockRepository.mockError = NetworkError.noData
        viewModel.useCombine = false
        
        // When
        let loadTask = Task { @MainActor in
            viewModel.loadPokemonList()
        }
        await loadTask.value
        
        // Add a small delay to ensure async operations complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.pokemonList.isEmpty)
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Combine Tests
    
    func testFetchPokemonListCombineSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch completes")
        mockRepository.shouldSucceed = true
        mockRepository.mockPokemonList = [
            Pokemon(name: "squirtle", url: "https://pokeapi.co/api/v2/pokemon/7/"),
            Pokemon(name: "pikachu", url: "https://pokeapi.co/api/v2/pokemon/25/")
        ]
        viewModel.useCombine = true
        
        // Observe changes
        viewModel.$pokemonList
            .dropFirst() // Skip initial empty value
            .sink { pokemonList in
                if !pokemonList.isEmpty {
                    // Then
                    XCTAssertEqual(pokemonList.count, 2)
                    XCTAssertEqual(pokemonList.first?.name, "squirtle")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.loadPokemonList()
        
        // Wait for expectation
        wait(for: [expectation], timeout: 1.0)
        
        // Additional assertions
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
}
