//
//  SwiftUIView.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-03.
//

import SwiftUI


struct PlayerSquare: View {
    
    /// If not square, the only a square part of this is shown
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
            ZStack {
                Color.clear // This acts as a placeholder to help enforce the aspect ratio
                    .aspectRatio(1.0, contentMode: .fit) // Enforce 1:1 aspect ratio
                
                image
                    .resizable()
                    .scaledToFill()
                    .opacity(poofed ? 0.30 : 1.0)
                    .saturation(poofed ? 0.7 : 1.0)
                    .layoutPriority(-1) // Ensure this view tries to fill the space without affecting the aspect ratio
            }
            .clipped() // Ensure the image does not overflow the bounds of the ZStack

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
            VStack(spacing: 20) {
                Button(action: {eliminated.toggle()}, label: {
                    Image(systemName: "hammer.fill")
                })

                PlayerSquare(
                    image: Image("1"),
                    poofed: $eliminated
                )
                .frame(width: 100, height: 100)
                .onTapGesture {
                    self.eliminated.toggle()
                }
                
                PlayerSquare(
                    image: Image(systemName: "cart"),
                    won: true
                )
                .frame(width: 100, height: 100)

                PlayerSquare(
                    image: Image("wide"),
                    lost: true
                )
                .frame(width: 100, height: 100)

                PlayerSquare(
                    image: Image("defaultHeadshot"),
                    lost: true
                )
                .frame(width: 100, height: 100)
            }
        }
    }

    return PreviewContainer()
}
