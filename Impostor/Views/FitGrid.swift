//
//  FitSquaresGrid.swift
//  Impostor
//
//  Created by William Entriken on 2024-01-04.
//

import SwiftUI

struct FitGrid<Item: Identifiable, ItemView: View>: View {
    let items: [Item]
    let content: (Item) -> ItemView
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    var aspectRatio: CGFloat = 1

    init(_ items: [Item], aspectRatio: CGFloat, horizontalPadding: CGFloat = 0, verticalPadding: CGFloat = 0, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let itemSize = itemViewSizeThatFits(
                count: items.count,
                size: geometry.size,
                atAspectRatio: aspectRatio
            )
            LazyVGrid(columns: [GridItem(.adaptive(minimum: itemSize.width), spacing: horizontalPadding)], spacing: verticalPadding) {
                ForEach(items) { item in
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

// A simple identifiable data model for the grid items
fileprivate struct GridItemModel: Identifiable, Equatable {
    let id: UUID
    let color: Color

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

// A simple view to represent each item in the grid
fileprivate struct ColorView: View {
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
    }
}

// The preview provider
struct AspectVGrid_Previews: PreviewProvider {
    static var previews: some View {
        ShufflingGridPreview()
    }

    struct ShufflingGridPreview: View {
        @State private var items = (1...8).map { index in
            GridItemModel(id: UUID(), color: Color.random())
        }

        // FYI: leaking, okay for preview
        let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

        var body: some View {
            FitGrid(items, aspectRatio: 1, horizontalPadding: 10, verticalPadding: 10) { item in
                ColorView(color: item.color)
            }
            .onReceive(timer) { _ in
                withAnimation {
                    items.shuffle()
                }
            }
        }
    }
}

// Add/remove
struct AspectVGrid2_Previews: PreviewProvider {
    static var previews: some View {
        ShufflingGridPreview()
    }
    
    struct ShufflingGridPreview: View {
        @State private var items = (1...7).map { index in
            GridItemModel(id: UUID(), color: Color.random())
        }

        func more() {
            withAnimation {
                items.append(GridItemModel(
                    id: UUID(),
                    color: Color.random()
                ))
            }
        }
        
        func less() {
            if items.count > 1 {
                withAnimation {
                    _ = items.popLast()
                }
            }
        }

        var body: some View {
            VStack {
                HStack {
                    Button(action: self.less, label: { Text("Less") })
                    Button(action: self.more, label: { Text("More") })
                }
                FitGrid(items, aspectRatio: 1, horizontalPadding: 10, verticalPadding: 10) { item in
                    ColorView(color: item.color)
                        //.bounceAppeared()
                        .wackyAppeared()
                }
                
//                .animation(.bouncy(duration: 0.5, extraBounce: 1.2), value: items)
            }
        }
    }
}

fileprivate extension Color {
    static func random() -> Color {
        Color(
            hue: Double.random(in: 0...1),
            saturation: Double.random(in: 0.2...0.8),
            brightness: Double.random(in: 0...0.95)
        )
    }
}

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
