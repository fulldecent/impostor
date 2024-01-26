//
//  ConfigurationScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

struct SharePhotoView: View {
    let players: [ImpostorGame.Player]
    let status: ImpostorGame.Status
    
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
                        image: PlayerImages.shared.image(forPlayerIndex: playerIndex.id),
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
                .wackyRotated()
            }
            
            bottomBar
        }
        .background(Image("background"))
    }
    
    var bottomBar: some View {
        let icon = UIImage(named: "AppIcon")!
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? ""
        
        return HStack(spacing: 12) {
            Image(uiImage: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            Text(appName)
                .font(.custom("American Typewriter", size: 16))
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

}

fileprivate struct IdentifiableInt: Identifiable {
    let id: Int
}

fileprivate extension View {
    func wackyRotated() -> some View {
        self.modifier(WackyRotatedModifier())
    }
}

fileprivate struct WackyRotatedModifier: ViewModifier {
    // Generate a random angle between -15 and +15 degrees
    private var randomAngle: Double {
        return Double.random(in: -20...20)
    }

    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: randomAngle))
    }
}

#Preview("Impostor won") {
    SharePhotoView(
        players: [
            .init(role: .normal, word: "Normal word"),
            .init(role: .normal, word: "Normal word"),
            .init(role: .impostor, word: "Impostor word")
        ],
        status: .impostorWon
    )
    .padding()
}

#Preview("Impostor defeated") {
    SharePhotoView(
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
            .init(role: .impostor, word: "Really long impostor word")
        ],
        status: .impostorDefeated
    )
    .padding()
}

#Preview("Painting into 800x1000") {
    let players: [ImpostorGame.Player] = [
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
    ]
    let status: ImpostorGame.Status = .impostorDefeated
    let renderer = ImageRenderer(
        content: SharePhotoView(players: players, status: status)
            .frame(width: 800, height: 1000)
    )
    let uiImage = renderer.uiImage!
    
    return VStack{Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
    }
    .scenePadding()
}
