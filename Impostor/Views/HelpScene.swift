//
//  HelpScene.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-13.
//

import SwiftUI

struct HelpPage {
    let image: Image
    let topText: String
    let bottomText: String
}

struct HelpPageView: View {
    let page: HelpPage

    var body: some View {
        VStack {
            Text(page.topText)
                .padding()
                .font(.custom("American Typewriter", size: 30))
                .fontWeight(.bold)

            page.image
                .resizable()
                .scaledToFit()

            Text(page.bottomText)
                .padding()
                .font(.custom("American Typewriter", size: 30))
        }
    }
}

struct HelpScene: View {
    @State private var selectedIndex = 0

    let pages = [
        HelpPage(
            image: Image("help1"),
            topText: "A party game",
            bottomText: "for 3–12 people"
        ),
        HelpPage(
            image: Image("help2"),
            topText: "Everyone sees their secret word",
            bottomText: "but the impostor's word is different"
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
    ]

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(pages.indices, id: \.self) { index in
                HelpPageView(page: pages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

fileprivate struct PreviewView: View {
    @State private var showHelpScene = false

    var body: some View {
        VStack {
            Button("Show Help") {
                showHelpScene = true
            }
            .sheet(isPresented: $showHelpScene) {
                HelpScene()
            }
        }
    }
}

#Preview {
    PreviewView()
}
