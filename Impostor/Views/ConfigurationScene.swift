//
//  ConfigurationScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

struct ConfigurationScene: View {
    let startGameWithPlayerCount: (Int) -> ()
    
    private struct Player: Identifiable, Equatable {
        let id = UUID()
        let index: Int
    }
    
    @State private var players: [Player] = (1...3).map { index in
        Player(index: index)
    }

    @State private var showHelpScene = false

    var body: some View {
        VStack(spacing: 20) {
            topBar
            
            FitGrid(players,
                    aspectRatio: 1, horizontalPadding: 12, verticalPadding: 12) { player in
                PlayerCard(
                    image: PlayerImages.shared.image(forPlayerIndex: player.index)
                )
                .bounceAppeared()
            }
            
            ImpostorButton(systemImageName: "play.fill") {
                startGameWithPlayerCount(players.count)
            }
            .frame(maxWidth: .infinity)

            bottomBar
        }
        .scenePadding()
        .background(Image("background"))
        .onAppear {
            AudioManager.shared.playBackgroundSound(named: "intro")
        }
        .onDisappear {
            AudioManager.shared.stopBackgroundSound()
        }
        .sheet(isPresented: $showHelpScene) {
            HelpScene()
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
                .impostorTextStyle()
                //.frame(maxWidth: .infinity) // Allows the text to take as much space as possible

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
                doFeedback()
            }

            ImpostorButton(systemImageName: "cart") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                // TODO: buy
                print("BUY")
            }
        }
    }
    
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

    func doFeedback() {
        let handle = "@fulldecent"
        let tweetText = "I have an idea for the Impostor game"
        // make it URL encoded
        let url = URL(string: "https://twitter.com/intent/tweet?text=\(handle) \(tweetText)")!
        UIApplication.shared.open(url)
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
    ConfigurationScene { count in
        print("Ready to start game with player count: ", count)
    }
}
