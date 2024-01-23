//
//  SwiftUIView.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-03.
//

//
//  SwiftUIView.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-03.
//

import SwiftUI

struct PlayerCard: View {
    @Binding var player: ImpostorGame.Player
    let status: ImpostorGame.Status
    let image: Image
    let ignoreEliminated: Bool
    var action: (() -> Void)? = nil

    private var eliminated: Bool { player.eliminated && !ignoreEliminated }
    private var won: Bool { player.role == .impostor && status == .impostorWon}
    private var lost: Bool { player.role == .impostor && status == .impostorDefeated}

    @State private var puffOpacity: Double = 0
    @State private var puffScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(1, contentMode: .fit) // square
                .opacity(eliminated ? 0.30 : 1.0)
                .saturation(eliminated ? 0.7 : 1.0)

            if won {
                Image("crown")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1.3)
            }

            if lost {
                Image("painted-cross")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            Image("puff")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(puffScale)
                .opacity(puffOpacity)
                .onChange(of: eliminated, initial: false) { oldValue, newValue in
                    if newValue {
                        // When eliminated becomes true
                        puffOpacity = 1.0
                        puffScale = 1.0
                        withAnimation(.easeOut(duration: 1.5)) {
                            puffOpacity = 0.0
                            puffScale = 4.0
                        }
                    } else {
                        // Reset when eliminated becomes false
                        puffOpacity = 0.0
                        puffScale = 1.0
                    }
                }
        }
        .onTapGesture {
            self.action?()
        }
    }
}

fileprivate struct PreviewHelper: View {
    @State private var player = ImpostorGame.Player(
        role: .normal,
        word: "A word",
        eliminated: false)

    var body: some View {
        VStack {
            Spacer()

            PlayerCard(
                player: $player,
                status: .showingSecretWordToPlayerWithIndex(0),
                image: PlayerImages.shared.image(forPlayerIndex: 0),
                ignoreEliminated: false,
                action: {
                    player.eliminated.toggle()
                    print("Toggled eliminated, now ", player.eliminated)
                }
            )
            .frame(width: 100, height: 100)

            Button("Toggle Eliminated") {
                player.eliminated.toggle()
            }
            
            Spacer()
            
            PlayerCard(
                player: .constant(ImpostorGame.Player(role: .impostor, word: "A word")),
                status: .impostorWon,
                image: Image("1"),
                ignoreEliminated: false
            )
            .frame(width: 100, height: 100)
            Spacer()
            
            PlayerCard(
                player: .constant(ImpostorGame.Player(role: .impostor, word: "A word")),
                status: .impostorDefeated,
                image: Image("2"),
                ignoreEliminated: false
            )
            .frame(width: 100, height: 100)

            Spacer()
        }
    }
}

#Preview {
    PreviewHelper()
}
