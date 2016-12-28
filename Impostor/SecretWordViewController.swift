//
//  SecretWordViewController.swift
//  Impostor
//
//  Created by William Entriken on 4/24/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit
import AudioToolbox
import CDAlertView
import FirebaseAnalytics

class SecretWordViewController: UIViewController {
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var playerImage: UIImageView!
    @IBOutlet weak var topSecretLabel: UILabel!
    var playerNumber: Int!
    
    fileprivate var game: ImpostorGameModel!
    fileprivate var imagePickerController: UIImagePickerController!
    fileprivate var imagePopoverController: UIPopoverController!
    fileprivate var wantsToTakePhoto = true
    fileprivate var photoDenied = false
    fileprivate var accentSoundId: SystemSoundID = {
        let url = Bundle.main.url(forResource: "peek", withExtension: "mp3")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        return soundID
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = ImpostorGameModel.game
        topSecretLabel.transform = CGAffineTransform(rotationAngle: -10 * CGFloat(M_PI) / 180.0)
        topSecretLabel.clipsToBounds = false
    }
    
    @IBAction func showSecretWord(_ sender: AnyObject) {
        AudioServicesPlaySystemSound(accentSoundId);
        let theWord = game.playerWords[playerNumber]
        
        let alertView = CDAlertView(title: NSLocalizedString("Your secret word is", comment: "On the secret word screen"),
                                    message: theWord,
                                    type: .custom(image: UIImage(named:"AppIcon60x60")!))
        alertView.alertBackgroundColor = UIColor.black
        alertView.titleTextColor = UIColor.white
        alertView.messageTextColor = UIColor.white
        alertView.titleFont = UIFont(name: "AmericanTypewriter", size: 20.0)!
        alertView.messageFont = UIFont(name: "AmericanTypewriter-Bold", size: 20.0)!
        
        let dismissBlock: (CDAlertViewAction) -> Void = {_ in
            if self.playerNumber == self.game.numberOfPlayers - 1 {
                self.game.doneShowingSecretWords()
                var viewControllers: [AnyObject] = self.navigationController!.viewControllers
                self.navigationController!.popToViewController(viewControllers[1] as! UIViewController, animated: true)
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newController = storyboard.instantiateViewController(withIdentifier: "secretWord") as! SecretWordViewController
            newController.playerNumber = self.playerNumber + 1
            self.navigationController!.pushViewController(newController, animated: true)
        }
        let action = CDAlertViewAction(title: NSLocalizedString("OK", comment: "Dismiss the popup"),
                                       font: UIFont(name: "AmericanTypewriter-Bold", size: 20.0)!,
                                       textColor: UIColor.white,
                                       backgroundColor: nil, handler: dismissBlock)
        alertView.add(action: action)
        alertView.show()
    }
    
    @IBAction func stopGame(_ sender: AnyObject) {
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view" as NSObject,
            kFIRParameterItemID:NSStringFromClass(type(of: self)) as NSObject
            ])
        
        self.playerLabel.text = String(format: NSLocalizedString("Player #%ld", comment: "Current player"), Int(self.playerNumber) + 1)
        
        let imageName = "\(Int(self.playerNumber))"
        if let photo = CachedPersistentJPEGImageStore.sharedStore.imageWithName(imageName) {
            self.playerImage.image = photo
            self.wantsToTakePhoto = false
        } else {
            self.playerImage.image = UIImage(named: "defaultHeadshot.png")!
            self.wantsToTakePhoto = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard self.wantsToTakePhoto && !self.photoDenied else {
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.delegate = self
            self.imagePickerController.sourceType = .camera
            self.imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                self.imagePickerController.cameraDevice = .front
            }
            self.present(self.imagePickerController, animated: true, completion: { _ in })
        }
    }
    
}

extension SecretWordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var photo = info[UIImagePickerControllerOriginalImage] as! UIImage
        photo = photo.normalizedImage().cropBiggestCenteredSquareImage(withSide: 800)
        let imageName: String = "\(Int(self.playerNumber))"
        CachedPersistentJPEGImageStore.sharedStore.saveImage(photo, withName: imageName)
        self.playerImage.image = photo
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.photoDenied = true
        picker.dismiss(animated: true, completion: { _ in })
    }
}

private extension UIImage {
    func normalizedImage() -> UIImage {
        if (self.imageOrientation == UIImageOrientation.up) {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    func cropBiggestCenteredSquareImage(withSide side: CGFloat) -> UIImage {
        if self.size.height == side && self.size.width == side {
            return self
        }
        let newSize = CGSize(width: side, height: side)
        let ratio: CGFloat
        let delta: CGFloat
        let offset: CGPoint
        if self.size.width > self.size.height {
            ratio = newSize.height / self.size.height
            delta = ratio * (self.size.width - self.size.height)
            offset = CGPoint(x: delta / 2, y: 0)
        }
        else {
            ratio = newSize.width / self.size.width
            delta = ratio * (self.size.height - self.size.width)
            offset = CGPoint(x: 0, y: delta / 2)
        }
        let clipRect = CGRect(x: -offset.x, y: -offset.y, width: ratio * self.size.width, height: ratio * self.size.height)
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)) {
            UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
        UIRectClip(clipRect)
        self.draw(in: clipRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
