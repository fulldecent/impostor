//
//  ImpostorApp.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//

// FIXME: go through all api ta make stuff private when needed

import SwiftUI

@main
struct ImpostorApp: App {
    var body: some Scene {
        WindowGroup {
            ImpostorAppView()
        }
    }
}

fileprivate struct ImpostorAppView: View {
    @State private var game: ImpostorGame?
    @State private var dummyVariableToUpdatePlayerPhotos = 0
    
    var body: some View {
        ZStack {
            switch game?.status {
            case nil:
                ConfigurationScene(startGameWithPlayerCount: startGameWithPlayerCount)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            case .showingSecretWord(playerIndex: let playerIndex):
                SecretWordScene(
                    playerIndex: playerIndex,
                    secretWord: game!.players[playerIndex].word,
                    close: { game!.finishedShowingSecretWord(withPlayerIndex: playerIndex) },
                    abortGame: { self.game = nil }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                .id(game!.status)
            case .voting(round: _, startingPlayerIndex: let playerIndex):
                VotingScene(
                    players: game!.players,
                    startingPlayerIndex: playerIndex,
                    imageForPlayerIndex: {
                        PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage
                    },
                    votedPlayer: { index in
                        AudioManager.shared.playSoundEffect(named: "eliminate")
                        withAnimation {
                            game!.eliminatePlayerWithIndex(index)
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                .id(game!.status)
            case .impostorWon, .impostorDefeated:
                ResultsScene(
                    players: game!.players,
                    status: game!.status,
                    imageForPlayerIndex: {
                        PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage
                    },
                    startNewGame: { self.game = nil }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut, value: game)
    }
    
    func startGameWithPlayerCount(_ count: Int) {
        game = .init(numberOfPlayers: count)
    }
}

#Preview {
    ImpostorAppView()
}
