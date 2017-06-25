//
//  CachedPersistentJPEGImageStore.swift
//  Impostor
//
//  Created by Full Decent on 2/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit

class CachedPersistentJPEGImageStore: NSObject {
    var cachedImages = [String : UIImage]()

    static let sharedStore = CachedPersistentJPEGImageStore()
    
    func saveImage(_ image: UIImage, withName name: String) {
        cachedImages[name] = image
        try? UIImageJPEGRepresentation(image, 0.9)?.write(to: urlForImageWithName(name), options: [.atomic])
    }
    
    func imageWithName(_ name: String) -> UIImage? {
        if TARGET_OS_SIMULATOR > 0 {
            if (name == "1") {
                return UIImage(contentsOfFile: "/Users/williamentriken/Developer/Impostor media/1.jpg")!
            }
            if (name == "2") {
                return UIImage(contentsOfFile: "/Users/williamentriken/Developer/Impostor media/4.jpg")!
            }
            if (name == "3") {
                return UIImage(contentsOfFile: "/Users/williamentriken/Developer/Impostor media/2.jpg")!
            }
            if (name == "4") {
                return UIImage(contentsOfFile: "/Users/williamentriken/Developer/Impostor media/3.jpg")!
            }
            if (name == "0") {
                return UIImage(contentsOfFile: "/Users/williamentriken/Developer/Impostor media/5.jpg")!
            }
        }
        if let image = cachedImages[name] {
            return image
        }
        if let data = try? Data(contentsOf: self.urlForImageWithName(name)) {
            return UIImage(data: data)!
        }
        return nil
    }
    
    func deleteImageWithName(_ name: String) {
        cachedImages.removeValue(forKey: name)
        let fileManager = FileManager.default
        _ = try? fileManager.removeItem(at: urlForImageWithName(name))
    }
    
    func deleteAllImages() {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let documentsURL = fileManager.urls(for: nsDocumentDirectory, in: nsUserDomainMask).last!
        for url in try! fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: []) {
            if url.lastPathComponent.hasPrefix("imagecache-") {
                _ = try? fileManager.removeItem(at: url)
            }
        }
    }
    
    func clearCache() {
        cachedImages.removeAll()
    }
    
    fileprivate func urlForImageWithName(_ name: String) -> URL {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let documentsURL = fileManager.urls(for: nsDocumentDirectory, in: nsUserDomainMask).last!
        let fileName = "imagecache-\(name).jpg"
        return documentsURL.appendingPathComponent(fileName)
    }    
}
