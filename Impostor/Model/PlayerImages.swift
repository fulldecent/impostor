//
//  PlayerImages.swift
//  Impostor
//
//  Created by William Entriken on 2023-12-31.
//

import SwiftUI

class PlayerImages {
    static let shared = PlayerImages()
    static let defaultImage = Image(uiImage: UIImage(named: "defaultHeadshot.png")!)
    private var cachedImages = [Int: Image]()
    
    func image(forPlayerIndex index: Int) -> Image {
        if let image = cachedImages[index] {
            return image
        }
        if let data = try? Data(contentsOf: url(forPlayerIndex: index)),
           let uiImage = UIImage(data: data) {
            let image = Image(uiImage: uiImage)
            cachedImages[index] = image
            return image
        }
        return Self.defaultImage
    }
    
    func save(_ uiImage: UIImage, forPlayerIndex index: Int) {
        // Convert UIImage to SwiftUI Image and update the cache
        let swiftUIImage = Image(uiImage: uiImage)
        cachedImages[index] = swiftUIImage

        // Convert UIImage to JPEG data
        guard let imageData = uiImage.jpegData(compressionQuality: 0.9) else {
            print("Error: Could not get JPEG representation of UIImage")
            return
        }

        // Write the JPEG data to disk
        do {
            let fileURL = url(forPlayerIndex: index)
            try imageData.write(to: fileURL, options: [.atomic])
        } catch {
            print("Error: Could not write image to disk with index \(index), error: \(error)")
        }
    }
    
    func deleteAll() {
        let fileManager = FileManager.default
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        for url in try! fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: []) {
            if url.lastPathComponent.hasPrefix("imagecache-") {
                _ = try? fileManager.removeItem(at: url)
            }
        }
        cachedImages.removeAll()
    }

    private func url(forPlayerIndex index: Int) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileName = "imagecache-\(index).jpg"
        return documentsURL.appendingPathComponent(fileName)
    }
}
