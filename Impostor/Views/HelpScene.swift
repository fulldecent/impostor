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

struct HelpScene: View {
    @State private var selectedIndex = 0

    let pages = [
        HelpPage(
            image: Image("help1"),
            topText: String(localized: "A party game", comment: "For game instructions page 1"),
            bottomText: String(localized: "for 3–12 people", comment: "For game instructions page 1")
        ),
        HelpPage(
            image: Image("help2"),
            topText: String(localized: "Everyone sees their secret word", comment: "For game instructions page 2"),
            bottomText: String(localized: "but the impostor's word is different", comment: "For game instructions page 2")
        ),
        HelpPage(
            image: Image("help3"),
            topText: String(localized: "Each round players describe their word", comment: "For game instructions page 3"),
            bottomText: String(localized: "then vote to eliminate one player", comment: "For game instructions page 3")
        ),
        HelpPage(
            image: Image("help4"),
            topText: String(localized: "To win", comment: "For game instructions page 4"),
            bottomText: String(localized: "the impostor must survive with one other player", comment: "For game instructions page 4")
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

fileprivate struct HelpPageView: View {
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

#Preview {
    struct HelpScenePreview: View {
        @State private var showHelpScene = false

        var body: some View {
            VStack {
                Button(action: {showHelpScene = true}, label: {
                    Image(systemName: "questionmark")
                })
                .sheet(isPresented: $showHelpScene) {
                    HelpScene()
                }
            }
        }
    }
    
    return HelpScenePreview()
}
