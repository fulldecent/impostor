//
//  SecretWordScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

struct SecretWordScene: View {
    let playerIndex: Int
    let secretWord: String
    
    let close: () -> Void
    let abortGame: () -> Void

    @State private var image: Image
    @State private var showingSecretWord = false
    @State private var isCameraPresented = false

    init(playerIndex: Int, secretWord: String, close: @escaping () -> Void, abortGame: @escaping () -> Void) {
        self.playerIndex = playerIndex
        self.secretWord = secretWord
        self.close = close
        self.abortGame = abortGame
        self.image = PlayerImages.shared.images[playerIndex] ?? PlayerImages.defaultImage
    }
    
    var body: some View {
        VStack {
            Text("Player \(playerIndex + 1)")
                .impostorTextStyle()

            ImpostorButton(systemImageName: "eye") {
                AudioManager.shared.playSoundEffect(named: "peek")
                showingSecretWord = true
            }
            
            Spacer()
            
            image
                .resizable()
                .scaledToFill()
            
            Text("TOP SECRET\nFor your eyes only")
                .impostorTextStyle()
                .background(.black)
                .rotationEffect(.degrees(-10))

            Spacer()

            HStack {
                Spacer()
                ImpostorButton(systemImageName: "xmark", action: abortGame)
                .frame(width: 50)
            }
        }
        .alert(secretWord, isPresented: $showingSecretWord, actions: {})
        .onChange(of: showingSecretWord, initial: false, { _, new in
            if !new {
                close()
            }    
        })
        .sheet(isPresented: $isCameraPresented) {
            CameraPicker(onImagePicked: playerTookSelfiePhoto)
        }
        .scenePadding()
        .background(Image("background"))
        .onAppear {
            isCameraPresented = PlayerImages.shared.images[playerIndex] == nil
        }
    }
    
    func playerTookSelfiePhoto(_ photo: UIImage) {
        PlayerImages.shared.save(photo, forPlayerIndex: playerIndex)
        self.image = PlayerImages.shared.images[playerIndex] ?? PlayerImages.defaultImage
        isCameraPresented = false
    }
}

#Preview {
    SecretWordScene(
        playerIndex: 3,
        secretWord: "A secret word",
        close: {
            print("Closing")
        },
        abortGame: {
            print("Aborting game")
        }
    )
}
