//
//  PlayerImages.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//

import SwiftUI
import Combine

class PlayerImages: ObservableObject {
    static let shared = PlayerImages()
    static let defaultImage = Image(uiImage: UIImage(named: "defaultHeadshot.png")!)
    private static let maxPlayerCount = 12

    @Published private(set) var images = [Image?](repeating: nil, count: maxPlayerCount)

    init() {
        for index in images.indices {
            if let data = try? Data(contentsOf: url(forPlayerIndex: index)),
               let uiImage = UIImage(data: data)
            {
                images[index] = Image(uiImage: uiImage)
            }
        }
    }

    func save(_ uiImage: UIImage, forPlayerIndex index: Int) {
        let swiftUIImage = Image(uiImage: uiImage)
        images[index] = swiftUIImage

        guard let imageData = uiImage.jpegData(compressionQuality: 0.9) else {
            print("Error: Could not get JPEG representation of UIImage")
            return
        }

        do {
            let fileURL = url(forPlayerIndex: index)
            try imageData.write(to: fileURL, options: [.atomic])
        } catch {
            print("Error: Could not write image to disk with index \(index), error: \(error)")
        }
    }
    
    func deleteAll() {
        let fileManager = FileManager.default
        for index in images.indices {
            let fileURL = url(forPlayerIndex: index)
            _ = try? fileManager.removeItem(at: fileURL)
            images[index] = nil
        }
    }

    private func url(forPlayerIndex index: Int) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileName = "playerimage-\(index).jpg"
        return documentsURL.appendingPathComponent(fileName)
    }
}
