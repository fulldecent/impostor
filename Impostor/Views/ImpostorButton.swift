//
//  ImpostorButton.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//

import SwiftUI

//TODO there's got to be a more Swifty way to customize Button and make custom initializers

func impostorButton(systemImageName: String, action: @escaping () -> Void) -> some View {
    return Button(
        action: action,
        label: {
            Image(systemName: systemImageName)
                .font(.system(size: 30, weight: .black))
        }
    )
    .buttonStyle(ImpostorButtonStyle())
}

func impostorButton(text: String, action: @escaping () -> Void) -> some View {
    return Button(
        action: action,
        label: {
            Text(text)
                .font(.custom("American Typewriter", size: 30))
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
        }
    )
    .buttonStyle(ImpostorButtonStyle())
}

func impostorButton<L: View>(label: L, action: @escaping () -> Void) -> some View {
    return Button(
        action: action,
        label: {
            label
        }
    )
    .buttonStyle(ImpostorButtonStyle())
}

fileprivate struct ImpostorButtonStyle: ButtonStyle {
    private let backgroundColor: Color = Color(hue: 0.6, saturation: 0.5, brightness: 1)
    private let shadowDepth: CGFloat = 6

    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .frame(maxWidth: .infinity)
            .padding(2)
            .frame(minWidth: 50, minHeight: 50)
            .font(.custom("American Typewriter", size: 30))
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .padding(.vertical, shadowDepth)
            .background(backgroundColor)
            .cornerRadius(10)
            .offset(y: configuration.isPressed ? shadowDepth : 0) // Moves down when pressed
            .shadow(color: backgroundColor.opacity(0.6), radius: 0, x: 0, y: configuration.isPressed ? 0 : shadowDepth)
    }
}

#Preview {
    VStack {
        Button(action: {
            print("tap")
        }, label: {
            Text("Button")
        })
        .buttonStyle(ImpostorButtonStyle())
        
        HStack {
            Button(action: {
                print("tap")
            }, label: {
                Text("Button")
            })
            .buttonStyle(ImpostorButtonStyle())

            impostorButton(systemImageName: "heart", action: {})
            
            Button(action: {
                print("tap")
            }, label: {
                Text("Button")
            })
            .buttonStyle(ImpostorButtonStyle())
        }
        
        HStack {
            Button(action: {
                print("tap")
            }, label: {
                Text("Button")
            })
            .buttonStyle(ImpostorButtonStyle())
            Text("hi there")
            Button(action: {
                print("tap")
            }, label: {
                Text("Button")
            })
            .buttonStyle(ImpostorButtonStyle())
        }
        
        impostorButton(text: "HI", action: {})
    }
    .padding()
}
