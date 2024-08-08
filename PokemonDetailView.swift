//
//  PokemonDetailView.swift
//  PhinconProject
//
//  Created by Eka Praditya on 08/08/24.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @State private var pokemonDetail: PokemonDetail?
    @State private var isShowingNicknameAlert = false
    @State private var nickname = ""

    var body: some View {
        VStack{
            if let pokemonDetail = pokemonDetail {
                VStack{
                    Text("\(pokemonDetail.name.uppercased())")
                        .font(.largeTitle).bold()
                        .fontDesign(.rounded)
                    
                    VStack{
                        if let frontShiny = pokemonDetail.sprites.frontShiny, let url = URL(string: frontShiny) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                        } else if let frontDefault = pokemonDetail.sprites.frontDefault, let url = URL(string: frontDefault) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 150, height: 150)
                    
                    ScrollView{
                        VStack{
                            HStack{
                                VStack {
                                    Text("Types")
                                        .font(.title)
                                    
                                    HStack{
                                        Spacer()
                                        if let firstType = pokemonDetail.types.first {
                                            Text(firstType.type.name)
                                                .font(.title2)
                                        } else {
                                            Text("No types available")
                                        }
                                        Spacer()
                                        if let lastType = pokemonDetail.types.last {
                                            Text(lastType.type.name)
                                                .font(.title2)
                                        } else {
                                            Text("No types available")
                                        }
                                        Spacer()
                                    }
                                    .padding(.bottom,40)
                                }
                            }
                            VStack {
                                Text("Moves")
                                    .font(.title)
                                
                                VStack{
                                    HStack{
                                        if !pokemonDetail.moves.isEmpty {
                                            if let randomMove = pokemonDetail.moves.randomElement()?.move {
                                                Text(randomMove.name)
                                            }
                                        } else {
                                            Text("No moves available")
                                        }
                                        Spacer()
                                        if !pokemonDetail.moves.isEmpty {
                                            if let randomMove = pokemonDetail.moves.randomElement()?.move {
                                                Text(randomMove.name)
                                            }
                                        } else {
                                            Text("No moves available")
                                        }
                                    }
                                    .padding(1)
                                    HStack{
                                        if !pokemonDetail.moves.isEmpty {
                                            if let randomMove = pokemonDetail.moves.randomElement()?.move {
                                                Text(randomMove.name)
                                            }
                                        } else {
                                            Text("No moves available")
                                        }
                                        Spacer()
                                        if !pokemonDetail.moves.isEmpty {
                                            if let randomMove = pokemonDetail.moves.randomElement()?.move {
                                                Text(randomMove.name)
                                            }
                                        } else {
                                            Text("No moves available")
                                        }
                                    }
                                }
                                .padding(.horizontal,20)
                            }
                        }
                    }
                }
                
                
                VStack{
                    ZStack{
                        Button(action: {
                            CatchPokemon()
                        }) {
                            Text("Catch")
                                .padding(40)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .font(.largeTitle)
                                .clipShape(Circle())
                            
                        }
                        .padding()
                        Button(action: {
                            CatchPokemon()
                        }) {
                            Text("Catch")
                                .padding(60)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red).opacity(0.3)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .font(.largeTitle)
                                .clipShape(Circle())
                            
                        }
                        .padding()
                        
                    }
                    .alert("Give a nickname to your Pokémon!", isPresented: $isShowingNicknameAlert) {
                                                TextField("Nickname", text: $nickname)
                                                Button("Save", action: {
                                                    let caughtPokemon = CaughtPokemon(pokemon: pokemon, nickname: nickname, sprite: pokemonDetail.sprites.frontShiny ?? "")
                                                    StorageManager.shared.saveCaughtPokemon(caughtPokemon)
                                                    isShowingNicknameAlert = false
                                                })
                                            }
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .onAppear {
            fetchPokemonDetails()
        }        
    }
    
    func fetchPokemonDetails() {
        guard let url = URL(string: pokemon.url) else {
            print("Invalid URL")
            return
        }
        PokemonAPI().fetchPokemonDetails(from: url) { pokemonDetail in
            self.pokemonDetail = pokemonDetail
        }
    }
    func CatchPokemon() {
            let randomNum = Double.random(in: 0...100)
            if randomNum <= 50 {
                isShowingNicknameAlert = true
            } else {
                showAlert(message: "The Pokémon broke free!")
            }
        }

        func showAlert(message: String) {
            let alert = UIAlertController(title: "Catch Result", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }

}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView(pokemon: Pokemon(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/6/"))
    }
}
