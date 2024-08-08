//
//  ContentView.swift
//  PhinconProject
//
//  Created by Eka Praditya on 08/08/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showPokemonList = false
    
    var body: some View {
        ZStack {
            if showPokemonList {
                PokemonListView()
            } else {
                Button("Show Pokemons") {
                    showPokemonList = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
