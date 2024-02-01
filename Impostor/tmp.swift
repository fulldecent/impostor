import SwiftUI
import UIKit

struct TmpView: View {
    var body: some View {
        let uiImage = UIImage(named: "help1")!
        let image = Image(uiImage: uiImage)
        let url = URL(string: "https://example.com")! // Replace with your desired URL

        VStack {
            ShareLink(
                item: image,
                preview: SharePreview(
                    "caption",
                    image: image
                )
            )
        }
    }
}

#Preview {
    TmpView()
}
