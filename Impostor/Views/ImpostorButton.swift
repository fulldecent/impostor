//
//  ImpostorButton.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//

import SwiftUI

struct ImpostorButton<Label: View>: View {
    let action: () -> Void
    let label: Label

    init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button(action: action, label: { label })
            .buttonStyle(ImpostorButtonStyle())
    }
}

extension ImpostorButton where Label == Text {
    init(_ text: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(text)
        }
    }
}

extension ImpostorButton where Label == Image {
    init(systemImageName: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Image(systemName: systemImageName)
        }
    }
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
            .fontWeight(.bold)
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .padding(.vertical, shadowDepth)
            .background(backgroundColor)
            .cornerRadius(10)
            .offset(y: configuration.isPressed ? shadowDepth : 0) // Moves down when pressed
            .shadow(color: backgroundColor.opacity(0.6), radius: 0, x: 0, y: configuration.isPressed ? 0 : shadowDepth)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var moveButton = false
        
        var body: some View {
            VStack {
                HStack {
                    Button(action: {
                        print("tap")
                    }, label: {
                        Text("Button2222")
                    })
                    .buttonStyle(ImpostorButtonStyle())
                    
                    ImpostorButton(systemImageName: "heart", action: {})
                    
                    Button(action: {
                        print("tap")
                    }, label: {
                        Text("Button")
                    })
                    .buttonStyle(ImpostorButtonStyle())
                    .font(.system(size: 30, weight: .black))
                    
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
                
                ImpostorButton("HI", action: {})
                
                // Animated button row
                HStack {
                    Spacer()
                    ImpostorButton("Bouncy", action: {})
                        .frame(width: UIScreen.main.bounds.width * 0.6)
                        .offset(x: UIScreen.main.bounds.width * (moveButton ? -0.2 : 0.2))
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                            value: moveButton
                            
                        )
                    Spacer()
                }
                .onAppear {
                    moveButton.toggle()
                    print(moveButton)
                }
                
            }
            .padding()
        }
    }
    return PreviewWrapper()
}
