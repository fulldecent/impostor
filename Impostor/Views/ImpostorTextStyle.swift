//
//  ImpostorTextStyle.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-25.
//

import SwiftUI

extension View {
    func impostorTextStyle() -> some View {
        self.modifier(ImpostorTextStyle())
    }
}

fileprivate struct ImpostorTextStyle: ViewModifier {
    var size: CGFloat = 30

    func body(content: Content) -> some View {
        content
            .font(.custom("American Typewriter", size: size))
            .fontWeight(.bold)
            .foregroundStyle(Color.white)
    }
}

#Preview {
    HStack {
        Text("A party game")
            .impostorTextStyle()
            .padding(20)
    }
    .background(Color.red)
}
