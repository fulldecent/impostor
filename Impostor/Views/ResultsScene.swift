//
//  ConfigurationScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

// FIXME: use the photo sharing from tmp.swift

struct ResultsScene: View {
    let players: [ImpostorGame.Player]
    let status: ImpostorGame.Status
    let imageForPlayerIndex: (Int) -> (Image)
    @State private var screenshot: UIImage?

    @State private var showShareSheet = false

    var aView = Text("hi")
    
    var body: some View {
        VStack(spacing: 20) {
            Text(status == .impostorWon
                 ? "Impostor won"
                 : "Impostor was defeated")
                .impostorTextStyle()

            FitGrid(players.indices.map { IdentifiableInt(id: $0) },
                    aspectRatio: 1, horizontalPadding: 12, verticalPadding: 12) { playerIndex in
                VStack {
                    PlayerCard(
                        image: imageForPlayerIndex(playerIndex.id),
                        won: players[playerIndex.id].role == .impostor && status == .impostorWon,
                        lost: players[playerIndex.id].role == .impostor && status == .impostorDefeated
                    )
                    .scaledToFit()
                    Text(players[playerIndex.id].word)
                        .font(.custom("American Typewriter", size: 16))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity) // Allows the text to take as much space as possible
                }
                .wackyAppeared()
            }
            
            bottomBar
        }
        .scenePadding()
        .background(Image("background"))
        .onAppear {
            switch status {
            case .impostorWon:
                AudioManager.shared.playBackgroundSound(named: "results-impostor-won", repeating: false)
            case .impostorDefeated:
                AudioManager.shared.playBackgroundSound(named: "results-impostor-defeated", repeating: false)
            default:
                break
            }
            
            // Slow screenshot render
            DispatchQueue.main.async {
                screenshot = makeScreenshot()
            }
        }
    }
    
    var bottomBar: some View {
        // Bottom actions
        return HStack(spacing: 12) {
            ImpostorButton(systemImageName: "play") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                // start new game
            }
            
            if let screenshot {
                let image = Image(uiImage: screenshot)

                // TODO: style this like a button
                ShareLink(
                    item: image,
                    preview: SharePreview(
                        "Group selfie",
                        image: image
                    )
                )
            }
        }
    }

    @MainActor func makeScreenshot() -> UIImage? {
        let renderer = ImageRenderer(
            content: SharePhotoView(
                players: players,
                status: status,
                imageForPlayerIndex: { PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage }
            )
                .frame(width: 800, height: 1000)
        )
        return renderer.uiImage
    }
}

fileprivate  struct IdentifiableInt: Identifiable {
    let id: Int
}

fileprivate extension View {
    func wackyAppeared() -> some View {
        self.modifier(WackyAppearedModifier())
    }
}

fileprivate struct WackyAppearedModifier: ViewModifier {
    @State private var appeared = false
    
    // Generate a random angle between -15 and +15 degrees
    private var randomAngle: Double {
        return Double.random(in: -20...20)
    }

    func body(content: Content) -> some View {
        content
            .rotationEffect(appeared ? Angle(degrees: randomAngle) : .zero) // Apply the initial rotation
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 40, damping: 2)) {
                    appeared = true
                }
            }
    }
}

#Preview("Impostor won") {
    ResultsScene(
        players: [
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .impostor, word: "Impostor word")
        ],
        status: .impostorWon,
        imageForPlayerIndex: { PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage }
    )
}

#Preview("Impostor defeated") {
    ResultsScene(
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
        status: .impostorDefeated,
        imageForPlayerIndex: { PlayerImages.shared.images[$0] ?? PlayerImages.defaultImage }
    )
}
