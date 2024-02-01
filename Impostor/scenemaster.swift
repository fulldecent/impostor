import SwiftUI

struct View1: View {
    var switchViewAction: () -> Void

    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
            Button(action: switchViewAction) {
                Text("Go to View 2")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
        }
    }
}

struct View2: View {
    var switchViewAction: () -> Void

    var body: some View {
        ZStack {
            Color.green.edgesIgnoringSafeArea(.all)
            Button(action: switchViewAction) {
                Text("Go to View 1")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
        }
    }
}

struct OrchestratorView: View {
    @State private var showView1 = true

    var body: some View {
        ZStack {
            if showView1 {
                View1(switchViewAction: switchToView2)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            } else {
                View2(switchViewAction: switchToView1)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut, value: showView1)
    }

    private func switchToView2() {
        showView1 = false
    }

    private func switchToView1() {
        showView1 = true
    }
}


#Preview {
    OrchestratorView()
}
