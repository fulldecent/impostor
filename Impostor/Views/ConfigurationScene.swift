//
//  ConfigurationScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI
import StoreKit

struct ConfigurationScene: View {
    let startGameWithPlayerCount: (Int) -> ()
    let storeManager = StoreManager.shared

    private struct Player: Identifiable, Equatable {
        let id = UUID()
        let index: Int
    }
    
    @State private var players: [Player] = (0..<3).map { index in
        Player(index: index)
    }

    @State private var showHelpScene = false
    @State private var showThankYouAlert = false

    var body: some View {
        let playerImages = PlayerImages.shared
        
        return VStack(spacing: 20) {
            topBar
            
            FitGrid(players,
                    aspectRatio: 1, horizontalPadding: 12, verticalPadding: 12) { player in
                PlayerSquare(
                    image: playerImages.images[player.index]
                    ?? PlayerImages.defaultImage
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
        .alert(isPresented: $showThankYouAlert) {
            Alert(title: Text("Thank you!"),
                  message: Text("Already purchased expanded word list"),
                  dismissButton: .default(Text("OK")))
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
                // Hack to redraw
                for index in players.indices {
                    players[index] = Player(index: index)
                }
            }

            ImpostorButton(systemImageName: "lightbulb") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                doFeedback()
            }

            ImpostorButton(systemImageName: storeManager.isPurchased ? "checkmark" : "cart") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                if storeManager.isPurchased {
                    showThankYouAlert = true
                } else {
                    storeManager.purchase()
                }
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

    private func doFeedback() {
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
