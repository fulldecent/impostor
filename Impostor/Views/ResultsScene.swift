//
//  ConfigurationScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-06.
//

import SwiftUI

struct ResultsScene: View {
    let players: [ImpostorGame.Player]
    let status: ImpostorGame.Status
    @State private var showShareSheet = false
    @State private var screenshot = UIImage(named: "defaultHeadshot.png")!

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
                        image: PlayerImages.shared.image(forPlayerIndex: playerIndex.id),
                        eliminated: .constant(players[playerIndex.id].eliminated),
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
        }
        .sheet(isPresented: $showShareSheet) {
            // Add your items to share here
            ActivityViewController(activityItems: [
                screenshot
            ])
        }
    }
    
    
    var bottomBar: some View {
        // Bottom actions
        HStack(spacing: 12) {
            ImpostorButton(systemImageName: "play") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                // start new game
            }
            
            ImpostorButton(systemImageName: "square.and.arrow.up") {
                AudioManager.shared.playSoundEffect(named: "buttonPress")
                showShareSheet = true
            }
            
            /*

            Button(action: {}, label: {
                ShareLink(item: URL(string: "https://developer.apple.com/xcode/swiftui/")!) {
                    Label("Share", image: "MyCustomShareIcon")
                }
            })

            ShareLink(item: URL(string: "https://developer.apple.com/xcode/swiftui/")!) {
                impostorButton(systemImageName: "square.and.arrow.up", action: {})
            }
             */
        }
    }
    
    /*
    @MainActor private func screenshot() -> UIImage {
        let renderer = ImageRenderer(content: body)
        let image = renderer.uiImage!

        print(image.size)
        print(image)
        return image
    }
    
    @MainActor private func share() {
        let screenshot = screenshot()
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let url = URL(string: "https://itunes.apple.com/us/app/whos-the-impostor/id784258202")!

        let activityItems: [Any] = [
            //screenshot
            UIImage(named: "defaultHeadshot.png")!
        ]
        
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(activityVC, animated: true)
    }
    
    private func getShareLink() -> some View {
        print("making share link")
        
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String

        let url = URL(string: "https://itunes.apple.com/us/app/whos-the-impostor/id784258202")!

        
        return ShareLink(
            item: Screenshot(body: body),
            preview: .init("a key", image: Image(systemName: "stop"))
        )
    }
    
    /*
    struct Screenshot2<Content: View>: Transferable {
        var body: Content

        // Mock asynchronous method to return an Image
        func generateImage() async -> Image {
            // Simulate asynchronous operation
            await Task.sleep(1_000_000_000)  // Waits for 1 second

            // Mock result - replace this with actual image generation logic
            let uiImage = UIImage(systemName: "photo") ?? UIImage()
            return Image(uiImage: uiImage)
        }

        static var transferRepresentation: some TransferRepresentation {
            ProxyRepresentation { screenshot in
                await screenshot.generateImage()
            }
        }
    }
     */

    struct Screenshot<Content: View>: Transferable {
        var body: Content

        @MainActor
        func generate() async -> Image {
            let renderer = ImageRenderer(content: body)
            let uiImage = renderer.uiImage!
            print(uiImage)
            return Image(uiImage: uiImage)
        }
        
        static var transferRepresentation: some TransferRepresentation {
            ProxyRepresentation { screenshot in
                Image(systemName: "play")
            }

            /*
            ProxyRepresentation { screenshot in
                await screenshot.generate()
            }
             */
        }
    }
     */

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
        status: .impostorWon
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
        status: .impostorDefeated
    )
}



struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: ["hi"], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
