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
                //.font(.title)
                .padding()
                .font(.custom("American Typewriter", size: 30))
                .fontWeight(.bold)

            page.image
                .resizable()
                .scaledToFit()

            Text(page.bottomText)
                //.font(.body)
                .padding()
                .font(.custom("American Typewriter", size: 30))
        }
    }
}

struct HelpScene: View {
    @State private var selectedIndex = 0
    let pages: [HelpPage]

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
                HelpScene(pages: [
                    HelpPage(image: Image(systemName: "1.circle"), topText: "Page 1 Top", bottomText: "Page 1 Bottom"),
                    HelpPage(image: Image(systemName: "2.circle"), topText: "Page 2 Top", bottomText: "Page 2 Bottom"),
                    HelpPage(image: Image(systemName: "3.circle"), topText: "Page 3 Top", bottomText: "Page 3 Bottom"),
                    HelpPage(image: Image(systemName: "4.circle"), topText: "Page 4 Top", bottomText: "Page 4 Bottom")
                ])
            }
        }
    }
}



#Preview {
    PreviewView()
}
