//
//  ConfigurationScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

// TODO: fix binding so that the poofed = true will animate as this view slides out

struct VotingScene: View {
    let players: [ImpostorGame.Player]
    let startingPlayerIndex: Int
    let imageForPlayerIndex: (Int) -> (Image)
    let votedPlayer: (Int) -> Void
    @State private var screenshot: UIImage?
    @State private var isSecretPresented = false
    @State private var votedPlayerIndex: Int? = nil

    var body: some View {
        let playerImages = PlayerImages.shared

        return VStack(spacing: 20) {
            Text("Which player was eliminated?")
                .multilineTextAlignment(.center)
                .impostorTextStyle()

            FitGrid(players.indices.map { IdentifiableInt(id: $0) },
                    aspectRatio: 1, horizontalPadding: 12, verticalPadding: 12) { playerIndex in
                VStack {
                    PlayerSquare(
                        image: playerImages.images[playerIndex.id] ?? PlayerImages.defaultImage,
                        poofed: Binding(
                            get: { players[playerIndex.id].eliminated },
                            set: { _ in }
                        )
                    )
                    .scaledToFit()
                    .onTapGesture {
                        if !players[playerIndex.id].eliminated {
                            votedPlayer(playerIndex.id)
                        }
                    }
                }
            }
        }
        .scenePadding()
        .background(Image("background"))
        .onAppear {
            isSecretPresented = true
        }
        .alert(isPresented: $isSecretPresented) {
            Alert(
                title: Text("Begin voting with"),
                message: Text("Player \(startingPlayerIndex + 1)")
            )
        }
    }
}

fileprivate struct IdentifiableInt: Identifiable {
    let id: Int
}

#Preview("Impostor won") {
    struct PreviewWrapper: View {
        @State var players: [ImpostorGame.Player] = [
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .impostor, word: "Impostor word")
        ]
        
        var body: some View {
            VotingScene(
                players: players, 
                startingPlayerIndex: 0,
                imageForPlayerIndex: { PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage },
                votedPlayer: {
                    index in players[index].eliminated = true
                    print("Voted player \(index + 1)")
                }
            )
        }
    }
    return PreviewWrapper()
}
