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

    /// Images guaranteed to be square
    @Published private(set) var images = [Image?](repeating: nil, count: maxPlayerCount)

    init() {
        for index in 0..<PlayerImages.maxPlayerCount {
            if let data = try? Data(contentsOf: url(forPlayerIndex: index)),
               let uiImage = UIImage(data: data)
            {
                print("Loaded image \(index)")
                images[index] = imageOfCenter(uiImage)
            }
        }
    }

    func save(_ uiImage: UIImage, forPlayerIndex index: Int) {
        guard let cropped = cropImageToSquare(uiImage) else {
            return
        }
        
        let swiftUIImage = Image(uiImage: cropped)
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
        for index in 0..<PlayerImages.maxPlayerCount {
            let fileURL = url(forPlayerIndex: index)
            _ = try? fileManager.removeItem(at: fileURL)
        }
        images = [Image?](repeating: nil, count: PlayerImages.maxPlayerCount)
    }

    private func url(forPlayerIndex index: Int) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileName = "playerimage-\(index).jpg"
        return documentsURL.appendingPathComponent(fileName)
    }
}

fileprivate func imageOfCenter(_ image: UIImage) -> Image {
    let cgImage = image.cgImage!
    let minEdge = min(cgImage.width, cgImage.height)
    let offsetX = (cgImage.width - minEdge) / 2
    let offsetY = (cgImage.height - minEdge) / 2
    let cropRect = CGRect(x: offsetX, y: offsetY, width: minEdge, height: minEdge)
    let croppedCGImage = cgImage.cropping(to: cropRect)!
    let croppedUIImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    return Image(uiImage: croppedUIImage)
}

fileprivate func cropImageToSquare(_ image: UIImage) -> UIImage? {
    guard let sourceCGImage = image.cgImage else { return nil }

    // Determine the size of the shortest side to make the crop square
    let sideLength = min(image.size.width, image.size.height)
    let xOffset = (image.size.width - sideLength) / 2.0
    let yOffset = (image.size.height - sideLength) / 2.0

    // Define the crop area
    let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength).integral

    // Perform the crop
    guard let croppedCGImage = sourceCGImage.cropping(to: cropRect) else { return nil }

    // Create and return the cropped UIImage, preserving the original image's scale and orientation
    return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
}
