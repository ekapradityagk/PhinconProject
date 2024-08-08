//  MyPokemonListView.swift
//  PhinconProject
//
//  Created by Eka Praditya on 08/08/24.
//

import SwiftUI

struct MyPokemonListView: View {
    @State private var caughtPokemons: [CaughtPokemon] = []
    @State private var showingRenameAlert = false
    @State private var showingReleaseAlert = false
    @State private var selectedPokemon: CaughtPokemon?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                if caughtPokemons.isEmpty {
                    Text("No Pokémon caught before")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(caughtPokemons, id: \.pokemon.id) { caughtPokemon in
                        HStack{
                            Spacer()
                            VStack {
                                AsyncImage(url: URL(string: caughtPokemon.sprite)!) {
                                    image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 150, height: 150)
                                VStack() {
                                    Text(caughtPokemon.nickname)
                                        .font(.title2)
                                    Text(caughtPokemon.pokemon.name)
                                        .font(.subheadline)
                                }
                                .onAppear(){
                                    print("test")
                                    print(caughtPokemon.pokemon.url)
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showingReleaseAlert = true
                                        selectedPokemon = caughtPokemon
                                    }) {
                                        Text("Release")
                                            .padding()
                                            .foregroundColor(.white)
                                            .background(.red)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingRenameAlert = true
                                        selectedPokemon = caughtPokemon
                                    }) {
                                        Text("Rename")
                                            .padding()
                                            .foregroundColor(.white)
                                            .background(.blue)
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("My Pokémon")
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
            })
            .onAppear {
                loadCaughtPokemons()
            }
            
        }
        .alert(isPresented: $showingRenameAlert) {
            Alert(title: Text("Rename Pokémon"), message: Text("rename nickname"), primaryButton: .default(Text("Rename")) {
                if let selectedPokemon = selectedPokemon {
                    renamePokemon(selectedPokemon)
                    showingRenameAlert = false
                }
            }, secondaryButton: .cancel())
        }
        .alert(isPresented: $showingReleaseAlert) {
            Alert(title: Text("Release Pokémon"), message: Text("Are you sure you want to release this Pokémon?"), primaryButton: .default(Text("Release")) {
                if let selectedPokemon = selectedPokemon {
                    releasePokemon(selectedPokemon)
                    showingReleaseAlert = false
                }
            }, secondaryButton: .cancel())
        }
    }

    func loadCaughtPokemons() {
        caughtPokemons = StorageManager.shared.getCaughtPokemons()
    }

    func releasePokemon(_ caughtPokemon: CaughtPokemon) {
        let randomNumber = generateRandomNumber()
        if isPrime(number: randomNumber) {
            StorageManager.shared.removeCaughtPokemon(caughtPokemon)
            loadCaughtPokemons()
            showAlert(title: "Success", message: "Pokémon has been released successfully")
        } else {
            showAlert(title: "Failed", message: "Failed to release Pokémon")
        }
    }

    func generateRandomNumber() -> Int {
        return Int.random(in: 1...100)
    }

    func isPrime(number: Int) -> Bool {
        if number <= 1 {
            return false
        }
        for i in 2...Int(sqrt(Double(number))) {
            if number % i == 0 {
                return false
            }
        }
        return true
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func renamePokemon(_ caughtPokemon: CaughtPokemon) {
        var fibonacciSequence = [0, 1]
        while fibonacciSequence.count < 20 {
            fibonacciSequence.append(fibonacciSequence[fibonacciSequence.count - 1] + fibonacciSequence[fibonacciSequence.count - 2])
        }
        
        if let index = caughtPokemons.firstIndex(where: { $0.id == caughtPokemon.id }) {
            let nicknameComponents = caughtPokemons[index].nickname.components(separatedBy: " - ")
            let baseNickname = nicknameComponents.first ?? caughtPokemons[index].nickname
            let fibonacciIndex = nicknameComponents.count - 1
            let newNickname = "\(baseNickname) - \(fibonacciSequence[fibonacciIndex])"
            caughtPokemons[index].nickname = newNickname
            StorageManager.shared.updateCaughtPokemon(caughtPokemons[index], nickname: newNickname)
            loadCaughtPokemons()
        }
    }
}

struct MyPokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        MyPokemonListView()
    }
}
