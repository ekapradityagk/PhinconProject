//
//  PokemonListView.swift
//  PhinconProject
//
//  Created by Eka Praditya on 08/08/24.
//

import SwiftUI

struct PokemonRowView: View {
    let pokemon: Pokemon
    @State private var pokemonSprites: PokemonSprites?

    var body: some View {
        NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
            VStack(alignment: .leading) {
                HStack{
                    VStack{
                        Spacer()
                        if let pokemonSprites = pokemonSprites {
                            AsyncImage(url: URL(string: pokemonSprites.sprites.frontDefault)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .frame(width: 80,height: 80)
                    .padding(.leading, 20)
//                    Spacer()
                    Text(pokemon.name)
                        .font(.largeTitle).bold()
                    Spacer()
                }
            }
        }
        .onAppear {
            fetchPokemonSprites(pokemon: pokemon)
        }
    }

    func fetchPokemonSprites(pokemon: Pokemon) {
        let pokemonAPI = PokemonAPI()
        let url = URL(string: pokemon.url)!
        pokemonAPI.fetchPokemonSprites(from: url) { pokemonSprites in
            self.pokemonSprites = pokemonSprites
        }
    }
}

struct HomeButtonView: View {
    @State private var isPresented = false

    var body: some View {
        Button(action: {
            isPresented = true
        }) {
            Image(systemName: "house")
                .imageScale(.large)
                .foregroundColor(.black)
        }
        .sheet(isPresented: $isPresented) {
            MyPokemonListView()
        }
    }
}

struct PokemonListView: View {
    @State private var pokemons: [Pokemon] = []
    @State private var nextPageURL: String?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(pokemons, id: \.id) { pokemon in
                            PokemonRowView(pokemon: pokemon)
                        }
                    }
                }
                if isLoading {
                    ProgressView()
                } else if let nextPageURL = nextPageURL {
                    Button("Load More") {
                        if let url = URL(string: nextPageURL) {
                            fetchPokemons(url: url)
                        }
                    }
                }
            }
            .navigationTitle("Pokemons")
            .navigationBarItems(trailing: HomeButtonView())
            .onAppear {
                fetchPokemons()
            }
        }
    }

    func fetchPokemons(url: URL? = nil) {
        isLoading = true
        var fetchURL: URL
        if let url = url {
            fetchURL = url
        } else {
            fetchURL = URL(string: PokemonAPI().baseURL)!
        }
        PokemonAPI().fetchPokemons(from: fetchURL) { pokemons in
            self.isLoading = false
            if let nextPage = fetchURL.absoluteString.components(separatedBy: "?").first {
                self.nextPageURL = nextPage + "?offset=" + String(pokemons.count)
            } else {
                self.nextPageURL = nil
            }
            self.pokemons.append(contentsOf: pokemons)
        }
    }
}

struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView()
    }
}
