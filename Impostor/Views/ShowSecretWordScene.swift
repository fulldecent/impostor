//
//  SecretWordScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

struct SecretWordModal: View {
    let secretWord: String
    @Binding var isPresented: Bool
    var onClose: () -> Void // Closure to be called when the modal closes

    var body: some View {
        VStack {
            Text("Your secret word is")
                .padding()
                .font(.custom("American Typewriter", size: 30))
                .foregroundColor(Color.white)

            Text(secretWord)
                .padding()
                .font(.custom("American Typewriter", size: 30))
                .fontWeight(.bold)
                .foregroundColor(Color.white)

            impostorButton(systemImageName: "forward") {
                isPresented = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Expand to fill the modal
        .background(Color.black)
        .onAppear {
            AudioManager.shared.playSoundEffect(named: "peek")
        }
        .onDisappear {
            onClose()
        }
    }
}

struct ShowSecretWordScene: View {
    let playerName: String
    let secretWord: String
    @Binding var image: Image
    let shouldAttemptTakePhoto: Bool
    let onDoneViewingSecretWord: () -> Void
    let onAbortGame: () -> Void

    @State private var showingSecretWord = false
    @State private var isCameraPresented = false

    var body: some View {
        VStack {
            Text(playerName)
                .font(.custom("American Typewriter", size: 30))
                .fontWeight(.bold)
                .foregroundStyle(Color.white)

            impostorButton(text: "Show secret word") {
                showingSecretWord = true
            }
            
            Spacer()
            
            image
                .resizable()
                .aspectRatio(1, contentMode: .fit)

            Text("TOP SECRET\nFor your eyes only")
                .font(.custom("American Typewriter", size: 30))
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .background(.black)
                .rotationEffect(.degrees(-10))

            Spacer()

            HStack {
                Spacer()
                impostorButton(systemImageName: "xmark") {
                    onAbortGame()
                }
                .frame(width: 50)
            }
        }
        .sheet(isPresented: $showingSecretWord) {
            SecretWordModal(
                secretWord: secretWord,
                isPresented: $showingSecretWord,
                onClose: {
                    onDoneViewingSecretWord()
                }
            )
        }
        .sheet(isPresented: $isCameraPresented) {
                    CameraPicker(image: $image)
        }
        .scenePadding()
        .background(Image("background"))
        .onAppear(perform: {
            isCameraPresented = shouldAttemptTakePhoto
        })
    }
}

#Preview {
    ShowSecretWordScene(
        playerName: "A player",
        secretWord: "A secret word",
        image: .constant(PlayerImages.shared.image(forPlayerIndex: 1)),
        shouldAttemptTakePhoto: false,
        onDoneViewingSecretWord: {
            print("Done viewing secret word")
        },
        onAbortGame: {
            print("Abort game")
        }
    )
}
