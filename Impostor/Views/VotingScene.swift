//
//  ConfigurationScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

struct VotingScene: View {
    let players: [ImpostorGame.Player]
    let imageForPlayerIndex: (Int) -> (Image)
    @State private var screenshot: UIImage?

    @State private var showShareSheet = false

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
                        image: playerImages.images[playerIndex.id] ?? PlayerImages.defaultImage
                    )
                    .scaledToFit()
                }
            }
        }
        .scenePadding()
        .background(Image("background"))
    }
}

fileprivate  struct IdentifiableInt: Identifiable {
    let id: Int
}

#Preview("Impostor won") {
    VotingScene(
        players: [
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .impostor, word: "Impostor word")
        ],
        imageForPlayerIndex: { PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage }
    )
}

#Preview("Impostor defeated") {
    VotingScene(
        players: [
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .impostor, word: "Really long impostor word")
        ],
        imageForPlayerIndex: { PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage }
    )
}
