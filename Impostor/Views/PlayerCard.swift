//
//  SwiftUIView.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-03.
//

import SwiftUI

struct PlayerCard: View {
    let image: Image
    @Binding var poofed: Bool
    let won: Bool
    let lost: Bool

    @State private var puffOpacity: Double = 0
    @State private var puffScale: CGFloat = 1.0

    init(image: Image, poofed: Binding<Bool> = .constant(false), won: Bool = false, lost: Bool = false) {
        self.image = image
        _poofed = poofed
        self.won = won
        self.lost = lost
    }

    var body: some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(1, contentMode: .fit) // square
                .opacity(poofed ? 0.30 : 1.0)
                .saturation(poofed ? 0.7 : 1.0)

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
                .onChange(of: poofed, initial: false) { oldValue, newValue in
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
                Button("Toggle Poofed") {
                    self.eliminated.toggle()
                }

                PlayerCard(
                    image: Image("1"),
                    poofed: $eliminated
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
