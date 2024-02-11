//
//  FitSquaresGrid.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-04.
//

import SwiftUI

struct FitGrid<Item, ItemView: View, ID: Hashable>: View {
    let items: [Item]
    let content: (Item) -> ItemView
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let aspectRatio: CGFloat
    let id: KeyPath<Item, ID>

    // For non-Identifiable items
    init(_ items: [Item], id: KeyPath<Item, ID>, aspectRatio: CGFloat = 1, horizontalPadding: CGFloat = 0, verticalPadding: CGFloat = 0, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.content = content
        self.id = id
    }

    // For Identifiable items
    init(_ items: [Item], aspectRatio: CGFloat = 1, horizontalPadding: CGFloat = 0, verticalPadding: CGFloat = 0, @ViewBuilder content: @escaping (Item) -> ItemView) where Item: Identifiable, ID == Item.ID {
        self.items = items
        self.aspectRatio = aspectRatio
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.content = content
        self.id = \Item.id
    }

    var body: some View {
        GeometryReader { geometry in
            let itemSize = itemViewSizeThatFits(
                count: items.count,
                size: geometry.size,
                atAspectRatio: aspectRatio
            )
            LazyVGrid(columns: [GridItem(.adaptive(minimum: itemSize.width), spacing: horizontalPadding)], spacing: verticalPadding) {
                ForEach(items, id: id) { item in
                    content(item)
                        .frame(width: itemSize.width, height: itemSize.height)
                }
            }
        }
    }

    /// Find size of item that fits
    /// - Parameters:
    ///   - count: Number of items to fit
    ///   - size: Total size
    ///   - aspectRatio: Width/height ratio for items
    /// - Returns: Size for item that fits `count` items with `aspectRatio` in a 2-d `size` grid
    private func itemViewSizeThatFits(
        count: Int,
        size: CGSize,
        atAspectRatio aspectRatio: CGFloat
    ) -> CGSize {
        var bestSize = CGSize.zero

        for columnCount in 1...count {
            let rowCount = ceil(CGFloat(count) / CGFloat(columnCount))
            let availableWidth = size.width - CGFloat(columnCount - 1) * horizontalPadding
            let availableHeight = size.height - (rowCount - 1) * verticalPadding
            let availableItemWidth = availableWidth / CGFloat(columnCount)
            let availableItemHeight = availableHeight / rowCount
            
            let itemWidth = min(availableItemWidth, availableItemHeight * aspectRatio)
            if itemWidth >= bestSize.width {
                bestSize = CGSize(width: itemWidth, height: itemWidth / aspectRatio)
            }
        }

        return bestSize
    }
}

//MARK: Previews

fileprivate extension View {
    func bounceAppeared() -> some View {
        self.modifier(BounceAppearedModifier())
    }
    func wackyAppeared() -> some View {
        self.modifier(WackyAppearedModifier())
    }
}

fileprivate struct BounceAppearedModifier: ViewModifier {
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1 : 0.1)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 250, damping: 15)) {
                    appeared = true
                }
            }
    }
}

fileprivate struct WackyAppearedModifier: ViewModifier {
    @State private var appeared = false
    
    // Generate a random angle between -15 and +15 degrees
    private var randomAngle: Double {
        return Double.random(in: -15...15)
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

fileprivate struct Paint: Identifiable {
    let color: Color
    let id: UUID
    
    static func random() -> Paint {
        Paint(
            color: .init(
                hue: Double.random(in: 0...1),
                saturation: Double.random(in: 0.2...0.8),
                brightness: Double.random(in: 0...0.95)
            ),
            id: UUID()
        )
    }
}

#Preview("Shuffling") {
    struct ShufflingGridPreview: View {
        @State var items: [Paint] = (1...8).map { _ in
            Paint.random()
        }
        let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

        func more() {
            withAnimation {
                items.append(Paint.random())
            }
        }

        func less() {
            guard items.count > 1 else {return}
            withAnimation {
                _ = items.popLast()
            }
        }

        var body: some View {
            VStack {
                HStack {
                    Button(action: less, label: { Image(systemName: "minus") } )
                    Button(action: more, label: { Image(systemName: "plus") } )
                }
                FitGrid(items, aspectRatio: 1, horizontalPadding: 10, verticalPadding: 10) { item in
                    Rectangle().fill(item.color)
                        .wackyAppeared()
                }
                .onReceive(timer) { _ in
                    withAnimation {
                        items.shuffle()
                    }
                }
            }
            .scenePadding()
        }
    }
    return ShufflingGridPreview()
}
