//
//  PokemonAPI.swift
//  PhinconProject
//
//  Created by Eka Praditya on 08/08/24.
//

import Foundation

struct PokemonAPI {
    let baseURL = "https://pokeapi.co/api/v2/pokemon"
    
    func fetchPokemons(from url: URL, completion: @escaping ([Pokemon]) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching pokemons: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("No data returned")
                completion([])
                return
            }
            
            do {
                let pokemonResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
                let pokemons = pokemonResponse.results.map { pokemonResult -> Pokemon in
                    return Pokemon(name: pokemonResult.name, url: pokemonResult.url)
                }
                completion(pokemons)
            } catch {
                print("Error parsing pokemons: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }
    
    func fetchPokemonDetails(from url: URL, completion: @escaping (PokemonDetail?) -> Void) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching pokemon details: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let data = data else {
                    print("No data returned")
                    completion(nil)
                    return
                }

                do {
                    let pokemonDetail = try JSONDecoder().decode(PokemonDetail.self, from: data)
                    completion(pokemonDetail)
                } catch {
                    print("Error parsing pokemon details: \(error.localizedDescription)")
                    completion(nil)
                }
            }.resume()
        }
    
    func fetchPokemonSprites(from url: URL, completion: @escaping (PokemonSprites?) -> Void) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching Pokémon sprites: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let data = data else {
                    print("No data returned")
                    completion(nil)
                    return
                }

                do {
                    let pokemonSprites = try JSONDecoder().decode(PokemonSprites.self, from: data)
                    completion(pokemonSprites)
                } catch {
                    print("Error decoding Pokémon sprites: \(error.localizedDescription)")
                    completion(nil)
                }
            }.resume()
        }
}

struct PokemonResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonResult]
}

struct PokemonResult: Codable {
    let name: String
    let url: String
}

struct Pokemon: Codable, Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        lhs.id == rhs.id
    }
}
struct PokemonDetail: Codable {
    let name: String
    let moves: [Move]
    let types: [PokemonType]
    let sprites: Sprites

    struct Move: Codable {
        let move: MoveInfo

        struct MoveInfo: Codable {
            let name: String
            let url: String
        }
    }

    struct PokemonType: Codable {
        let type: TypeInfo

        struct TypeInfo: Codable {
            let name: String
            let url: String
        }
    }

    struct Sprites: Codable {
        let frontShiny: String?
        let frontDefault: String?

        enum CodingKeys: String, CodingKey {
            case frontShiny = "front_shiny"
            case frontDefault = "front_default"
        }
    }
}

struct PokemonSprites: Codable {
    let sprites: PokemonSpriteUrls

    enum CodingKeys: String, CodingKey {
        case sprites
    }
}

struct PokemonSpriteUrls: Codable {
    let frontDefault: String

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct CaughtPokemon: Codable, Identifiable {
    let id = UUID()
    let pokemon: Pokemon
    var nickname: String
    let sprite: String
}

class StorageManager {
    static let shared = StorageManager()
    private let userDefaults = UserDefaults.standard

    func saveCaughtPokemon(_ caughtPokemon: CaughtPokemon) {
        var caughtPokemons = getCaughtPokemons()
        if let index = caughtPokemons.firstIndex(where: { $0.pokemon.id == caughtPokemon.pokemon.id }) {
            caughtPokemons[index] = caughtPokemon
        } else {
            caughtPokemons.append(caughtPokemon)
        }
        do {
            let data = try JSONEncoder().encode(caughtPokemons)
            userDefaults.set(data, forKey: "caughtPokemons")
        } catch {
            print("Error saving caught Pokémon: \(error)")
        }
    }

    func getCaughtPokemons() -> [CaughtPokemon] {
        guard let data = userDefaults.data(forKey: "caughtPokemons") else {
            return []
        }
        do {
            return try JSONDecoder().decode([CaughtPokemon].self, from: data)
        } catch {
            print("Error loading caught Pokémon: \(error)")
            return []
        }
    }

    func removeCaughtPokemon(_ caughtPokemon: CaughtPokemon) {
        var caughtPokemons = getCaughtPokemons()
        if let index = caughtPokemons.firstIndex(where: { $0.id == caughtPokemon.id }) {
            caughtPokemons.remove(at: index)
            do {
                let data = try JSONEncoder().encode(caughtPokemons)
                userDefaults.set(data, forKey: "caughtPokemons")
            } catch {
                print("Error removing caught Pokémon: \(error)")
            }
        }
    }
    
    func updateCaughtPokemon(_ caughtPokemon: CaughtPokemon, nickname: String) {
        var caughtPokemons = getCaughtPokemons()
        if let index = caughtPokemons.firstIndex(where: { $0.pokemon.id == caughtPokemon.pokemon.id }) {
            caughtPokemons[index].nickname = nickname
            do {
                let data = try JSONEncoder().encode(caughtPokemons)
                userDefaults.set(data, forKey: "caughtPokemons")
            } catch {
                print("Error updating caught Pokémon: \(error)")
            }
        }
    }
}
