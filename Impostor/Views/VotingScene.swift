//
//  ConfigurationScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

struct VotingScene: View {
    let players: [ImpostorGame.Player]
    let currentPlayerIndex: Int
    let imageForPlayerIndex: (Int) -> (Image)
    let votedPlayer: (Int) -> Void
    @State private var screenshot: UIImage?
    @State private var isAlertPresented = false

    var aView = Text("hi")
    
    var body: some View {
        let playerImages = PlayerImages.shared

        return VStack(spacing: 20) {
            Text("Which player was eliminated?")
                .multilineTextAlignment(.center)
                .impostorTextStyle()

            FitGrid(players.indices.map { IdentifiableInt(id: $0) },
                    aspectRatio: 1, horizontalPadding: 12, verticalPadding: 12) { playerIndex in
                VStack {
                    PlayerCard(
                        image: playerImages.images[playerIndex.id] ?? PlayerImages.defaultImage,
                        
                        // FIXME:
                        eliminated: .constant(players[playerIndex.id].eliminated)
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
            isAlertPresented = true
        }
        .alert("Voting begins with", isPresented: $isAlertPresented, actions: {
            Button("OK", action: { isAlertPresented = false })
        }, message: {
            Text("Player \(currentPlayerIndex + 1)")
        })
        
        .sheet(isPresented: $isAlertPresented, content: {
            VStack {
                Text("This is the alert content!")
                Button("Dismiss") {
                    isAlertPresented = false
                }
            }
            .padding()
        })
    }
}

fileprivate  struct IdentifiableInt: Identifiable {
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
                currentPlayerIndex: 4,
                imageForPlayerIndex: { PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage },
                votedPlayer: { index in players[index].eliminated = true }
            )
        }
    }
    return PreviewWrapper()
}
