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
    
    func saveImage(image: UIImage, withName name: String) {
        cachedImages[name] = image
        UIImageJPEGRepresentation(image, 0.9)?.writeToURL(urlForImageWithName(name), atomically: true)
    }
    
    func imageWithName(name: String) -> UIImage? {
        if TARGET_OS_SIMULATOR > 0 {
            if (name == "1") {
                return UIImage(contentsOfFile: "/Users/fulldecent/Developer/Impostor media/1.jpg")!
            }
            if (name == "2") {
                return UIImage(contentsOfFile: "/Users/fulldecent/Developer/Impostor media/4.jpg")!
            }
            if (name == "3") {
                return UIImage(contentsOfFile: "/Users/fulldecent/Developer/Impostor media/2.jpg")!
            }
            if (name == "4") {
                return UIImage(contentsOfFile: "/Users/fulldecent/Developer/Impostor media/3.jpg")!
            }
            if (name == "0") {
                return UIImage(contentsOfFile: "/Users/fulldecent/Developer/Impostor media/5.jpg")!
            }
        }
        if let image = cachedImages[name] {
            return image
        }
        if let data = NSData(contentsOfURL: self.urlForImageWithName(name)) {
            return UIImage(data: data)!
        }
        return nil
    }
    
    func deleteImageWithName(name: String) {
        cachedImages.removeValueForKey(name)
        let fileManager = NSFileManager.defaultManager()
        _ = try? fileManager.removeItemAtURL(urlForImageWithName(name))
    }
    
    func deleteAllImages() {
        let fileManager = NSFileManager.defaultManager()
        let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
        let nsUserDomainMask = NSSearchPathDomainMask.UserDomainMask
        let documentsURL = fileManager.URLsForDirectory(nsDocumentDirectory, inDomains: nsUserDomainMask).last!
        for url in try! fileManager.contentsOfDirectoryAtURL(documentsURL, includingPropertiesForKeys: nil, options: []) {
            if url.lastPathComponent!.hasPrefix("imagecache-") {
                _ = try? fileManager.removeItemAtURL(url)
            }
        }
    }
    
    func clearCache() {
        cachedImages.removeAll()
    }
    
    private func urlForImageWithName(name: String) -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
        let nsUserDomainMask = NSSearchPathDomainMask.UserDomainMask
        let documentsURL = fileManager.URLsForDirectory(nsDocumentDirectory, inDomains: nsUserDomainMask).last!
        let fileName = "imagecache-\(name).jpg"
        return documentsURL.URLByAppendingPathComponent(fileName)
    }    
}
