//
//  ConfigurationScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

struct ConfigurationScene: View {
    struct Player: Identifiable, Equatable {
        let id = UUID()
        let index: Int
    }
    
    @State private var players: [Player] = (1...3).map { index in
        Player(index: index)
    }

    @State private var showHelpScene = false

    private func increaseNumberOfPlayers() {
        if players.count < 12 {
            players.append(Player(index: players.count))
        }
    }

    private func decreaseNumberOfPlayers() {
        if players.count > 3 {
            withAnimation {
                _ = players.popLast()
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            topBar
            
            FitGrid(players,
                    aspectRatio: 1, horizontalPadding: 12, verticalPadding: 12) { player in
                PlayerCard(
                    player: .constant(ImpostorGame.Player(
                        role: .impostor, word: "")),
                    status: .showingSecretWordToPlayerWithIndex(0),
                    image: PlayerImages.shared.image(forPlayerIndex: player.index),
                    ignoreEliminated: true)
                .bounceAppeared()
            }
            
            ImpostorButton(systemImageName: "play.fill") {
                // TODO PLAY GAME
            }
            .frame(maxWidth: .infinity)

            bottomBar
        }
        .scenePadding()
        .background(Image("background"))
        .onAppear {
            AudioManager.shared.playBackgroundSound(named: "intro")
        }
        .sheet(isPresented: $showHelpScene) {
            helpScene
        }
    }
    
    var topBar: some View {
        HStack {
            ImpostorButton(systemImageName: "minus") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                decreaseNumberOfPlayers()
            }
            .frame(maxWidth: 60)
            
            Spacer()
            
            Text("\(players.count) PLAYERS")
                .font(.custom("American Typewriter", size: 30))
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity) // Allows the text to take as much space as possible

            Spacer()
            
            ImpostorButton(systemImageName: "plus") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                increaseNumberOfPlayers()
            }
            .frame(maxWidth: 60)
        }
        .frame(maxWidth: .infinity)
    }
    
    var bottomBar: some View {
        // Bottom actions
        HStack(spacing: 12) {
            ImpostorButton(systemImageName: "questionmark") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                showHelpScene = true
            }
            
            ImpostorButton(systemImageName: "trash") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                PlayerImages.shared.deleteAll()
            }

            ImpostorButton(systemImageName: "lightbulb") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                let handle = "@fulldecent"
                let tweetText = "I have an idea for the Impostor game"
                // make it URL encoded
                let url = URL(string: "https://twitter.com/intent/tweet?text=\(handle) \(tweetText)")!
                UIApplication.shared.open(url)
            }

            ImpostorButton(systemImageName: "cart") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                // TODO: buy
            }
        }
    }
    
    var helpScene: some View {
        HelpScene(pages: [
            HelpPage(
                image: Image("help1"),
                topText: "A party game",
                bottomText: "For 3–12 people"
            ),
            HelpPage(
                image: Image("help2"),
                topText: "Everyone sees their secret word",
                bottomText: "But the impostor's word is different"
            ),
            HelpPage(
                image: Image("help3"),
                topText: "Each round players describe their word",
                bottomText: "then vote to eliminate one player (can't use word to describe itself or repeat other players, break ties with a revote)"
            ),
            HelpPage(
                image: Image("help4"),
                topText: "To win",
                bottomText: "the impostor must survive with one other player"
            )
        ])
    }
}

fileprivate extension View {
    func bounceAppeared() -> some View {
        self.modifier(BounceAppearedModifier())
    }
}

fileprivate struct BounceAppearedModifier: ViewModifier {
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1 : 0.1)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 250, damping: 15)) {
                    appeared = true
                }
            }
    }
}

#Preview {
    ConfigurationScene()
}
