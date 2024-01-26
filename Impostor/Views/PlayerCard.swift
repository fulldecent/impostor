//
//  SwiftUIView.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-03.
//

import SwiftUI

struct PlayerCard: View {
    let image: Image
    @Binding var eliminated: Bool
    var won: Bool = false
    var lost: Bool = false

    @State private var puffOpacity: Double = 0
    @State private var puffScale: CGFloat = 1.0

    init(image: Image, eliminated: Binding<Bool> = .constant(false), won: Bool = false, lost: Bool = false) {
        self.image = image
        _eliminated = eliminated
        self.won = won
        self.lost = lost
    }

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
    }
}

#Preview {
    struct PreviewContainer: View {
        @State var eliminated: Bool = false

        var body: some View {
            VStack {
                Button("Toggle Eliminated") {
                    self.eliminated.toggle()
                }

                PlayerCard(
                    image: Image("1"),
                    eliminated: $eliminated
                )
                .frame(width: 100, height: 100)
                .onTapGesture {
                    self.eliminated.toggle()
                }
            }
        }
    }

    return VStack(spacing: 20) {
        PreviewContainer()

        PlayerCard(
            image: Image("2"),
            won: true
        )
        .frame(width: 100, height: 100)

        PlayerCard(
            image: Image("3"),
            lost: true
        )
        .frame(width: 100, height: 100)
    }
}
